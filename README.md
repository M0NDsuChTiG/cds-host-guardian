# 🛡️ CDS Host Guardian: The Digital Bunker

[![Kernel](https://img.shields.io/badge/Kernel-LSM%20%2F%20eBPF-red?style=for-the-badge&logo=linux)](https://kernel.org)
[![Language](https://img.shields.io/badge/Language-Go%20%2F%20C-blue?style=for-the-badge&logo=go)](https://go.dev)
[![Security](https://img.shields.io/badge/Security-Zero%20Trust-green?style=for-the-badge&logo=scuba)](https://en.wikipedia.org/wiki/Zero_trust_security_model)

**CDS Host Guardian** — это бескомпромиссная система защиты хоста, превращающая стандартную Linux-среду в неприступную крепость. Используя мощь **eBPF** и **Linux Security Modules (LSM)**, агент внедряет логику Zero Trust напрямую в Ring 0.

---

## 🔒 Четыре Столпа Защиты (LSM Shields)

| Модуль | Описание | Уровень Угрозы |
| :--- | :--- | :---: |
| **📦 MOUNT SHIELD** | Блокировка `sb_mount`. Никаких побегов из контейнеров или несанкционированного доступа к ФС. | 🔴 Critical |
| **🕵️ ANTI-DEBUG** | Блокировка `ptrace`. Полная изоляция памяти процессов от инъекций и анализа. | 🟠 High |
| **👑 PRIVILEGE GUARD** | Блокировка `task_fix_setuid`. Иммунитет к SUID-эксплойтам и повышению прав до root. | 🔴 Critical |
| **🌐 NETWORK JAIL** | Блокировка `socket_connect`. Нулевая сетевая активность для недоверенных сред (Zero Exfiltration). | 🟠 High |

---

## 🏗️ Архитектура: Zero Trust by Cgroup ID

В отличие от классических систем, полагающихся на нестабильные PID, **CDS Host Guardian** использует `cgroup_id` (v2) как единственный источник истины.

```text
[ USER SPACE ]          [ KERNEL SPACE (Ring 0) ]
      |                             |
[ CDS AGENT ] <-------+------> [ BPF MAP: Trusted Groups ]
      |               |             |
      |          [ AUTHORIZE ]      |
      |               |             v
[ LOADER.GO ]         +------- [ LSM HOOKS (LSM_BPF) ]
                                    |
                         [ ALLOW / DENY DECISION ]
```

---

## ⚡ Быстрый Старт

### Требования
*   Linux Kernel >= 5.7 (с поддержкой `CONFIG_BPF_LSM=y`)
*   Clang/LLVM & Go 1.21+

### Развертывание
```bash
# 1. Сборка нативного ядра безопасности
cd bpf && make

# 2. Активация лоадера
go generate ./...
go build -o cds-guardian ./cmd/loader

# 3. Запуск "Цифрового Бункера"
sudo ./cds-guardian
```

---

## 🛠️ Технологический Стек
*   **eBPF Runtime:** Нативная обработка событий в ядре без оверхеда.
*   **C / CO-RE:** Портируемость между версиями ядер (Compile Once – Run Everywhere).
*   **Golang Control Plane:** Современный, безопасный и быстрый интерфейс управления.

---
> **Disclaimer:** Этот проект создан для обеспечения максимальной безопасности. Использование в "боевых" условиях требует предварительной настройки белых списков cgroups.

*Created by [M0NDsuChTiG](https://github.com/M0NDsuChTiG) with focus on uncompromising system integrity.*
