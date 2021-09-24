#!/bin/bash
PATH="/usr/local/bin:/usr/bin:/bin"
# set -euxo pipefail

push_tmp_path="./action.tmp"

function urlencode() {
    # urlencode <string>

    old_lang=$LANG
    LANG=C

    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for ((i = 0; i < length; i++)); do
        local c="${1:i:1}"
        case $c in
        [a-zA-Z0-9.~_-]) printf "$c" ;;
        *) printf '%%%02X' "'$c" ;;
        esac
    done

    LANG=$old_lang
    LC_COLLATE=$old_lc_collate
}

function weather() {
    wget -O "yanta.png" "wttr.in/雁塔区.png?lang=zh"
    wget -O "jingtai.png" "wttr.in/景泰县.png?lang=zh"
}

function update_msg() {
    title="<strong>MyActions Update ⚠️</strong>\n\n"
    repo="https://github.com/JaimeZeng/MyActions"
    author="$(git log -1 --pretty=format:'%cn')"
    date="$(git log -1 --pretty=format:'%ci')"
    hash="$(git log -1 --pretty=format:'%h')"
    files="$(git log -1 --name-status --format='')"
    commitLink="https://github.com/JaimeZeng/MyActions/commit/$(git log -1 --pretty=format:'%H')"
    file="\n"
    fileLink="https://github.com/JaimeZeng/MyActions/blob/main/"
    for var in $(echo "${files}" | cut -f2); do
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

function send_msg() {
    if [[ "${tg_bot_token}" ]] && [[ "${tg_user_id}" ]]; then
        echo -e "chat_id=${tg_user_id}&text=${message}&parse_mode=HTML&disable_web_page_preview=true" >${push_tmp_path}
        push=$(curl -k -s --data-binary @${push_tmp_path} "https://api.telegram.org/bot${tg_bot_token}/sendMessage")
        push_code=$(echo ${push} | grep -o '"ok":true')
        if [[ ${push_code} ]]; then
            echo -e "TelegramBot 推送结果: 成功"
        else
            echo -e "TelegramBot 推送结果: 失败"
        fi
    fi
}

function send_photo() {
    if [[ "${tg_bot_token}" ]] && [[ "${tg_user_id}" ]]; then
        echo -e "chat_id=${tg_user_id}&photo=wttr.in/雁塔区.png?lang=zh" >${push_tmp_path}
        push=$(curl -k -s --data-binary @${push_tmp_path} "https://api.telegram.org/bot${tg_bot_token}/sendPhoto")
        push_code=$(echo ${push} | grep -o '"ok":true')
        if [[ ${push_code} ]]; then
            echo -e "TelegramBot 推送结果: 成功"
        else
            echo -e "TelegramBot 推送结果: 失败"
        fi
    fi
}

if [[ "$1" == "updateMsg" ]]; then
    update_msg
    send_msg
fi
