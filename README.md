# CDS Host Guardian

**Защита хоста на уровне файловой системы и контейнеров**

Объединённая система Zero-Trust, которая защищает одновременно:
- **Что запускается** — Docker-образы (digest + cosign + fail-closed)
- **На чём запускается** — Btrfs rootfs (интеграция + самовосстановление)

## 🎮 CDS Security Lab

**[Открыть интерактивный тренажёр →](https://m0ndsuchtig.github.io/cds-host-guardian/)**

Здесь ты можешь:
- Намеренно «сломать» Btrfs
- Попробовать восстановить систему
- Увидеть, как CDS автоматически обнаруживает повреждения и блокирует запуск контейнеров

## Состав проекта

- **cds-authz-system** — Zero-Trust авторизация Docker
- **btrfs-root-hunter** — Защита и восстановление Btrfs

## Установка

```bash
git clone --recurse-submodules https://github.com/M0NDsuChTiG/cds-host-guardian.git
cd cds-host-guardian
sudo ./install.sh
sudo systemctl restart docker
```

## Лицензия

MIT

---

**CDS Host Guardian** — это не просто два инструмента вместе.  
Это целостная система, которая защищает хост от атак на уровне контейнеров и файловой системы.
