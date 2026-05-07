#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>

char LICENSE[] SEC("license") = "GPL";

// Карта для хранения доверенных (разрешенных) cgroup_id.
struct {
    __uint(type, BPF_MAP_TYPE_HASH);
    __uint(max_entries, 4096);
    __type(key, u64);   // cgroup_id
    __type(value, u32); // Флаг (1 = trusted)
} trusted_groups SEC(".maps");

// 1. LSM хук на операцию монтирования (sb_mount)
SEC("lsm/sb_mount")
int BPF_PROG(cds_restrict_mount, const char *dev_name, const struct path *path,
             const char *type, unsigned long flags, void *data)
{
    u64 cg_id = bpf_get_current_cgroup_id();
    u32 *is_trusted = bpf_map_lookup_elem(&trusted_groups, &cg_id);
    
    if (is_trusted && *is_trusted == 1) return 0;

    bpf_printk("CDS_LSM: Unauthorized mount blocked for cgroup_id %llu\n", cg_id);
    return -1; 
}

// 2. LSM хук на ptrace (ptrace_access_check)
// Блокирует попытки отладки (ptrace) процессов со стороны недоверенных групп.
// Это защищает наш агент и другие критические процессы от инъекций кода.
SEC("lsm/ptrace_access_check")
int BPF_PROG(cds_restrict_ptrace, struct task_struct *child, unsigned int mode)
{
    u64 cg_id = bpf_get_current_cgroup_id();
    u32 *is_trusted = bpf_map_lookup_elem(&trusted_groups, &cg_id);

    if (is_trusted && *is_trusted == 1) {
        // Разрешаем ptrace только для доверенных групп (например, для нашего лоадера)
        return 0;
    }

    // Блокируем ptrace для всех остальных
    bpf_printk("CDS_LSM: Unauthorized PTRACE attempt by cgroup_id %llu blocked\n", cg_id);
    return -1; // EPERM
}

// 3. LSM хук на изменение UID (task_fix_setuid)
// Предотвращает повышение привилегий (Privilege Escalation) через SUID-бинарники
// или системные вызовы setuid в недоверенных cgroups.
SEC("lsm/task_fix_setuid")
int BPF_PROG(cds_restrict_setuid, struct cred *new, const struct cred *old, int flags)
{
    u64 cg_id = bpf_get_current_cgroup_id();
    u32 *is_trusted = bpf_map_lookup_elem(&trusted_groups, &cg_id);

    // Если процесс уже рутовый (UID 0), мы позволяем ему оставаться рутовым.
    // Мы блокируем именно ПЕРЕХОД от обычного пользователя к root (0) в недоверенных группах.
    if (old->uid.val != 0 && new->uid.val == 0) {
        if (!is_trusted || *is_trusted != 1) {
            bpf_printk("CDS_LSM: Privilege escalation blocked for cgroup_id %llu\n", cg_id);
            return -1; // EPERM
        }
    }

    return 0;
}

// 4. LSM хук на сетевые соединения (socket_connect)
// Блокирует исходящие соединения для недоверенных cgroups.
// Это предотвращает Reverse Shell и эксфильтрацию данных.
SEC("lsm/socket_connect")
int BPF_PROG(cds_restrict_network, struct socket *sock, struct sockaddr *address, int addrlen)
{
    u64 cg_id = bpf_get_current_cgroup_id();
    u32 *is_trusted = bpf_map_lookup_elem(&trusted_groups, &cg_id);

    if (is_trusted && *is_trusted == 1) {
        // Доверенным процессам (агенту) разрешено общение с внешним миром
        return 0;
    }

    // Блокируем любые попытки сетевых соединений для всех остальных
    bpf_printk("CDS_LSM: Unauthorized NETWORK connection attempt by cgroup_id %llu blocked\n", cg_id);
    return -1; // EPERM
}
