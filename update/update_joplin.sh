#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
set -euxo pipefail

#============================================================
#	System Required: Ubuntu
#	Description: Download Joplin And Upload
#	Version: 0.0.3
#	Author: JaimeZeng
#	Blog: https://www.zxj.guru/
#============================================================
sh_ver="0.0.3"
cur_dir=$(
    cd "$(dirname '$0')"
    pwd
)
datetime=$(date +"%Y-%m-%d %T")
user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"
github_workflow="https://github.com/JaimeZeng/MyActions/actions/workflows/Update_Joplin.yaml"
update_log="${cur_dir}/update.log"
push_tmp_path="${cur_dir}/action.tmp"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
joplin_version="${cur_dir}/joplin_version"
joplin_new_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/laurent22/joplin/releases/latest | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g')

function send_msg() {
    if [[ "${tg_bot_token}" ]] && [[ "${tg_user_id}" ]]; then
        message=$(cat ${update_log})
        echo -e "chat_id=${tg_user_id}&text=${message}&parse_mode=HTML&disable_web_page_preview=true" >${push_tmp_path}
        push=$(curl -k -s --data-binary @${push_tmp_path} "https://api.telegram.org/bot${tg_bot_token}/sendMessage")
        push_code=$(echo ${push} | grep -o '"ok":true')
        if [[ ${push_code} ]]; then
            echo -e "${Info} TelegramBot 推送结果: 成功"
        else
            echo -e "${Error} TelegramBot 推送结果: 失败"
        fi
    fi
}

function clean_file() {
    cd ${cur_dir}/ && rm -rf ${joplin_new_ver} ${update_log} ${push_tmp_path}
}

function upload_joplin() {
    cd ${cur_dir}
    ./LightUploader -c onedrive.json -f "${joplin_new_ver}" -r "public/github-release/laurent22-joplin/" -t 6 -b 20 >>${update_log}
}

function download_joplin() {
    [[ -z ${joplin_new_ver} ]] && echo -e "${Error} Joplin 最新版本获取失败 !" >>${update_log} && exit 1
    echo -e "${Info} 即将准备下载 Joplin 版本为 [ ${joplin_new_ver} ]" >>${update_log}
    mkdir -p ${cur_dir}/${joplin_new_ver} && cd ${cur_dir}/${joplin_new_ver}
    curl -fsSL -A "${user_agent}" https://api.github.com/repos/laurent22/joplin/releases/latest | jq -r ".assets[].browser_download_url" | xargs -I {} curl -A "${user_agent}" -L -S -O {}
    joplin_appimage_name="Joplin-${joplin_new_ver}.AppImage"
    joplin_sha512_name="Joplin-${joplin_new_ver}.AppImage.sha512"
    joplin_dmg_name="Joplin-${joplin_new_ver}.dmg"
    joplin_setup_name="Joplin-Setup-${joplin_new_ver}.exe"
    joplin_protable_name="JoplinPortable.exe"
    joplin_latest_linux_name="latest-linux.yml"
    joplin_latest_name="latest.yml"
    for joplin_file in "${joplin_appimage_name}" "${joplin_sha512_name}" "${joplin_dmg_name}" "${joplin_setup_name}" "${joplin_protable_name}" "${joplin_latest_name}" "${joplin_latest_name}"; do
        if [ ! -s "${joplin_file}" ]; then
            echo -e "${Error} ${joplin_file} 下载失败 !" >>${update_log} && exit 1
        fi
    done
    upload_joplin
}

function check_new_ver() {
    # joplin_new_ver=$(curl -fsSL -A "${user_agent}" https://api.github.com/repos/laurent22/joplin/releases/latest | jq -r ".tag_name"｜sed "s/v//g")
    joplin_new_ver=$(wget --no-check-certificate -qO- https://api.github.com/repos/laurent22/joplin/releases/latest | grep -o '"tag_name": ".*"' | head -n 1 | sed 's/"//g;s/v//g' | sed 's/tag_name: //g')
    [[ -z ${joplin_new_ver} ]] && echo -e "${Error} Joplin 最新版本获取失败 !" >>${update_log} && exit 1
    echo -e "${Info} 检测到 Joplin 最新版本为 [ ${joplin_new_ver} ]" >>${update_log}
}

function check_now_ver() {
    joplin_now_ver=$(cat joplin_version)
    [[ -z ${joplin_now_ver} ]] && echo -e "${Error} Joplin 当前版本获取失败 !" >>${update_log} && exit 1
}

function check_ver_comparison() {
    # check_new_ver
    # check_now_ver
    download_joplin
    # if [[ "${joplin_now_ver}" != "${joplin_new_ver}" ]]; then
    #     echo -e "${Info} 发现 Joplin 已有新版本 [ ${joplin_new_ver} ](当前版本：${joplin_now_ver})" >>${update_log}
    #     download_joplin
    # else
    #     echo -e "${Info} 当前 Joplin 已是最新版本 [ ${joplin_new_ver} ]" >>${update_log} && exit 1
    # fi
}

echo -e "<strong>Joplin Update ⚠️</strong>\n" >${update_log}
echo -e "- date: ${datetime}" >>${update_log}
echo -e "- workflow: <a href='${github_workflow}'> 👉🏻 Github Workflow </a>" >>${update_log}
echo -e "\n====== log ======" >>${update_log}
check_ver_comparison
send_msg
clean_file
