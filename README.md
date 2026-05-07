# CDS Host Guardian: Host-Level Zero Trust Shield

**CDS Host Guardian** — это высокопроизводительная система защиты хоста на базе eBPF (LSM), реализующая концепцию Zero Trust в Ring 0 ядра Linux.

## Ключевые функции безопасности (LSM Hooks)

Система реализует политику **Default Deny** для всех несанкционированных процессов, не входящих в доверенные cgroups:

1.  **Mount Protection (`sb_mount`):** Блокирует несанкционированные операции монтирования, предотвращая побеги из контейнеров (container escapes) и несанкционированный доступ к файловым системам.
2.  **Anti-Debugging (`ptrace_access_check`):** Запрещает использование `ptrace` для недоверенных процессов, защищая память критических служб от инъекций шелл-кода и динамического анализа.
3.  **Privilege Escalation Prevention (`task_fix_setuid`):** Блокирует попытки повышения привилегий до `root` через SUID-бинарники или системные вызовы `setuid` для изолированных сред.
4.  **Network Lockdown (`socket_connect`):** Реализует строгий Egress-фильтр, запрещая любые исходящие сетевые соединения для недоверенных cgroups (блокировка Reverse Shell и эксфильтрации данных).

## Технологический стек

*   **Ядро:** C (eBPF / LSM)
*   **Загрузчик:** Go (cilium/ebpf)
*   **Идентификация:** cgroup_id (v2) — для надежной изоляции в контейнерных средах.

## Архитектура

Проект состоит из двух частей:
*   `bpf/`: Исходный код eBPF-сенсора на C.
*   `cmd/loader/`: Загрузчик на Go, который динамически извлекает `cgroup_id` агента, авторизует его в ядре и активирует все уровни защиты.

## Установка и запуск

1. Скомпилируйте BPF-объект:
   ```bash
   cd bpf && make
   ```
2. Соберите и запустите загрузчик:
   ```bash
   go generate ./...
   go build -o cds-guardian ./cmd/loader
   sudo ./cds-guardian
   ```

---
*Developed with focus on uncompromising security and system integrity.*
