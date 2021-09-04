#!/bin/bash
PATH="/usr/local/bin:/usr/bin:/bin"
# set -euxo pipefail

TELEGRAMBOT_TOKEN="1904539307:AAFzLkpxpalwsNd0ArGBJB46im-M07ALtkE"
TELEGRAMBOT_CHATID="799728773"
PUSH_TMP_PATH="./action.tmp"

urlencode() {
    # urlencode <string>

    old_lang=$LANG
    LANG=C
    
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done

    LANG=$old_lang
    LC_COLLATE=$old_lc_collate
}

update_msg(){
    title="<strong>MyActions Update ⚠️</strong>\n\n"
    repo="https://github.com/JaimeZeng/MyActions"
    author="$(git log -1 --pretty=format:'%cn')"
    date="$(git log -1 --pretty=format:'%ci')"
    hash="$(git log -1 --pretty=format:'%h')"
    files="$(git log -1 --name-status --format='')" 
    commitLink="https://github.com/JaimeZeng/MyActions/commit/$(git log -1 --pretty=format:'%H')"
    file="\n"
    fileLink="https://github.com/JaimeZeng/MyActions/blob/main/"
    for var in $(echo "${files}" | cut -f2)
    do
        file="${file}    ▫ <a href='${fileLink}${var}'> ${var} </a>\n"
    done
    message="" 
    message="${title}🔸 提交: ${repo}\n" 
    message="${message}🔸 提交者: ${author}\n" 
    message="${message}🔸 提交时间: ${date}\n" 
    message="${message}🔸 提交哈希值: ${hash}\n" 
    message="${message}🔸 具体提交信息: <a href='${commitLink}'> 👉🏻 Github </a>\n" 
    message="${message}🔸 提交变动文件: ${file}\n"
}

send_msg(){
    if [ "${TELEGRAMBOT_TOKEN}" ] && [ "${TELEGRAMBOT_CHATID}" ]; then
        echo -e "chat_id=${TELEGRAMBOT_CHATID}&parse_mode=HTML&text=${message}" >${PUSH_TMP_PATH}
        push=$(curl -k -s --data-binary @${PUSH_TMP_PATH} "https://api.telegram.org/bot${TELEGRAMBOT_TOKEN}/sendMessage")
        push_code=$(echo ${push} | grep -o '"ok":true')
        if [ ${push_code} ]; then
            echo -e "TelegramBot 推送结果: 成功"
        else
            echo -e "TelegramBot 推送结果: 失败"
        fi
    fi
}

if [ "$1" == "updateMsg" ]; then
    update_msg
fi
send_msg
