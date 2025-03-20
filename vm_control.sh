#!/bin/bash
VM_NAME="game"
SERIAL_PORT="/dev/ttyACM0"

echo "Запуск сервера управления ВМ через $SERIAL_PORT..."

if [ ! -e "$SERIAL_PORT" ]; then
  echo "Ошибка: $SERIAL_PORT не существует."
  exit 1
fi

# Открываем порт, читаем команды и фильтруем только нужные
cat "$SERIAL_PORT" | while read -r command; do
  echo "Получено сообщение: $command" # Добавляем вывод для диагностики
  case "$command" in
    start|stop|reboot|shutdown|resume)
      echo "Получена команда: $command"
      virsh "$command" "$VM_NAME"
      ;;
    *)
      echo "Игнорируем сообщение: $command"
      ;;
  esac
done
