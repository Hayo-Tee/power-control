#!/bin/bash

VM_NAME="game"
SERIAL_PORT="/dev/ttyACM0"
LOG_FILE="/boot/config/plugins/user.scripts/vm_control.log"

# Функция логирования
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG_FILE"
}

log_message "Запуск скрипта мониторинга команд ВМ через $SERIAL_PORT..."

# Проверка наличия serial порта
if [ ! -e "$SERIAL_PORT" ]; then
    log_message "Ошибка: $SERIAL_PORT не существует"
    exit 1
fi

# Настройка serial порта
stty -F $SERIAL_PORT 115200 raw -echo

# Функция выполнения команды virsh
execute_vm_command() {
    local command=$1
    log_message "Выполняется команда: virsh $command $VM_NAME"
    
    # Проверяем статус ВМ до выполнения команды
    local current_status=$(virsh domstate "$VM_NAME" 2>/dev/null)
    log_message "Текущий статус ВМ: $current_status"
    
    # Выполняем команду
    if virsh "$command" "$VM_NAME"; then
        log_message "Команда $command выполнена успешно"
        sleep 2
        local new_status=$(virsh domstate "$VM_NAME" 2>/dev/null)
        log_message "Новый статус ВМ: $new_status"
    else
        log_message "ОШИБКА: Не удалось выполнить команду $command"
    fi
}

# Читаем данные из serial порта
while read -r line < $SERIAL_PORT; do
    log_message "Получено: $line"
    
    # Убираем пробелы и перевод строки
    command=$(echo "$line" | tr -d '\n\r' | tr -d ' ')
    
    case "$command" in
        "start")
            log_message "Команда запуска ВМ"
            execute_vm_command "start"
            ;;
        "stop")
            log_message "Команда остановки ВМ"
            execute_vm_command "shutdown"
            ;;
        "destroy")
            log_message "Команда принудительной остановки ВМ"
            execute_vm_command "destroy"
            ;;
        "reboot")
            log_message "Команда перезагрузки ВМ"
            execute_vm_command "reboot"
            ;;
        *)
            if [ ! -z "$command" ]; then
                log_message "Получена неизвестная команда: $command"
            fi
            ;;
    esac
done

log_message "Скрипт завершил работу"
