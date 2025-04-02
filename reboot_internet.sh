#!/bin/bash

# Параметры роутера
ROUTER_IP="10.10.1.1"
USERNAME="user"       # Логин
PASSWORD="user"    # Пароль
LOGIN_URL="http://$ROUTER_IP/login.htm"
REBOOT_URL_BASE="http://$ROUTER_IP/maintenance/saveandreboot_tl.xgi"

# Функция для вычисления MD5-хеша
md5_hash() {
    echo -n "$1" | md5sum | awk '{print $1}'
}

# Проверка доступности роутера
ping -q -c 1 "$ROUTER_IP" > /dev/null || { echo "Роутер недоступен"; exit 1; }

# Вычисляем MD5-хеш пароля
PASSWORD_HASH=$(md5_hash "$PASSWORD")

# Шаг 1: Авторизация
# Отправляем POST-запрос с логином и хешем пароля
# -L: Следуем перенаправлениям
# --user-agent: Указываем User-Agent
curl -X POST \
     -L \
     --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
     -d "f_username=$USERNAME&f_password=$PASSWORD_HASH&f_currURL=$LOGIN_URL" \
     -c cookies.txt \
     -o login_response.html \
     "$LOGIN_URL"

# Шаг 2: Проверяем cookies.txt
if [ ! -s cookies.txt ]; then
    echo "Ошибка: cookies.txt пустой. Проверьте логин/пароль."
    exit 1
fi

# Шаг 3: Загружаем страницу /status/st_deviceinfo_tl.htm, чтобы найти sessionKey
curl -L \
     --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
     -b cookies.txt \
     -o device_info.html \
     "http://$ROUTER_IP/status/st_deviceinfo_tl.htm"

# Шаг 4: Извлечение sessionKey
# Предполагаем, что sessionKey может быть в URL или в HTML
SESSION_KEY=$(grep -oP 'sessionKey=\K\d+' device_info.html)

if [ -z "$SESSION_KEY" ]; then
    # Если sessionKey не найден, пробуем загрузить страницу перезагрузки
    curl -L \
         --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
         -b cookies.txt \
         -o reboot_page.html \
         "http://$ROUTER_IP/maintenance/mt_system_tl.htm"
    SESSION_KEY=$(grep -oP 'sessionKey=\K\d+' reboot_page.html)
fi

if [ -z "$SESSION_KEY" ]; then
    echo "Не удалось извлечь sessionKey. Проверьте доступные страницы."
    exit 1
fi

# Шаг 5: Формируем URL для перезагрузки
REBOOT_URL="$REBOOT_URL_BASE?sessionKey=$SESSION_KEY"

# Шаг 6: Отправка запроса на перезагрузку
curl -L \
     --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" \
     -b cookies.txt \
     "$REBOOT_URL"

if [ $? -eq 0 ]; then
    echo "Команда на перезагрузку отправлена"
else
    echo "Ошибка при отправке команды"
fi

# Шаг 7: Удаляем временные файлы
rm -f cookies.txt login_response.html device_info.html reboot_page.html