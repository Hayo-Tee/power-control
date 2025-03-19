#!/bin/bash
VM_NAME="game"
SERIAL_PORT="/dev/ttyACM0"

echo "Запуск сервера управления ВМ через $SERIAL_PORT..."

# Открываем порт, читаем команды и фильтруем только нужные
cat "$SERIAL_PORT" | while read -r command; do
  case "$command" in
    start_vm|stop_vm|reboot_vm|force_vm)
      echo "Получена команда: $command"
      virsh "$command" "$VM_NAME"
      ;;
    *)
      echo "Игнорируем сообщение: $command"
      ;;
  esac
done
