package main

//go:generate go run github.com/cilium/ebpf/cmd/bpf2go -target amd64 bpf ../../bpf/shield.bpf.c

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
)

func main() {
	StartShield()
}

// getCgroupID извлекает ID контрольной группы текущего процесса.
// В Linux это можно сделать через stat() системного пути cgroup.
func getCgroupID() (uint64, error) {
	// Мы используем путь к cgroup v2 текущего процесса
	file, err := os.Open("/proc/self/cgroup")
	if err != nil {
		return 0, err
	}
	defer file.Close()

	// В cgroup v2 обычно одна строка "0::/..."
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, "0::") {
			parts := strings.Split(line, ":")
			if len(parts) >= 3 {
				// Получаем inode директории cgroup, который и является cgroup_id в ядре
				var stat syscall.Stat_t
				cgPath := fmt.Sprintf("/sys/fs/cgroup%s", parts[2])
				if err := syscall.Stat(cgPath, &stat); err != nil {
					// Если путь пустой (root cgroup), проверяем корень
					if parts[2] == "/" {
						syscall.Stat("/sys/fs/cgroup", &stat)
					} else {
						return 0, err
					}
				}
				return stat.Ino, nil
			}
		}
	}
	return 0, fmt.Errorf("cgroup v2 не найдена")
}

func StartShield() {
	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatalf("[-] ОШИБКА: memlock: %v", err)
	}

	var objs bpfObjects
	if err := loadBpfObjects(&objs, nil); err != nil {
		log.Fatalf("[-] ОШИБКА: BPF load: %v", err)
	}
	defer objs.Close() 

	// 3. Аттач LSM-программ к хукам ядра
	mountLink, err := link.AttachLSM(link.LSMOptions{
		Program: objs.CdsRestrictMount,
	})
	if err != nil {
		log.Fatalf("[-] ОШИБКА: LSM mount attach: %v", err)
	}
	defer mountLink.Close()

	ptraceLink, err := link.AttachLSM(link.LSMOptions{
		Program: objs.CdsRestrictPtrace,
	})
	if err != nil {
		log.Fatalf("[-] ОШИБКА: LSM ptrace attach: %v", err)
	}
	defer ptraceLink.Close()

	setuidLink, err := link.AttachLSM(link.LSMOptions{
		Program: objs.CdsRestrictSetuid,
	})
	if err != nil {
		log.Fatalf("[-] ОШИБКА: LSM setuid attach: %v", err)
	}
	defer setuidLink.Close()

	netLink, err := link.AttachLSM(link.LSMOptions{
		Program: objs.CdsRestrictNetwork,
	})
	if err != nil {
		log.Fatalf("[-] ОШИБКА: LSM network attach: %v", err)
	}
	defer netLink.Close()

	log.Println("[+] CDS LSM Shields (mount, ptrace, setuid & network) успешно загружены в Ring 0.")


	// 4. Логика авторизации: работаем с cgroup_id вместо PID
	cgID, err := getCgroupID()
	if err != nil {
		log.Printf("[!] ПРЕДУПРЕЖДЕНИЕ: Не удалось получить cgroup_id: %v. Используем ручной ввод или дефолт.", err)
		cgID = 1 // Root cgroup fallback
	}
	
	isTrusted := uint32(1)
	if err := objs.TrustedGroups.Put(cgID, isTrusted); err != nil {
		log.Fatalf("[-] ОШИБКА: Не удалось обновить BPF-карту: %v", err)
	}
	log.Printf("[+] cgroup_id (%d) добавлен в белый список (trusted_groups).", cgID)

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt, syscall.SIGTERM)
	
	log.Println("[*] Защита активна (Zero Trust by cgroup). Блокировка mount() запущена.")
	<-sig
	log.Println("[*] Демонтаж eBPF-щита...")
}
