#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# set -euxo pipefail

#============================================================
#	System Required: Ubuntu
#	Description: Download Chrome Extensions And Upload Onedrive
#	Version: 0.0.2
#	Author: JaimeZeng
#	Blog: https://www.zxj.guru/
#============================================================
sh_ver="0.0.2"
cur_dir=$(
    cd "$(dirname '$0')"
    pwd
)
datetime=$(date +"%Y-%m-%d %T")
user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.82 Safari/537.36"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

function clean_file() {
    cd ${cur_dir}/ && rm -f *.crx
}

function upload_crx() {
    cd ${cur_dir}/
    for file in *.crx; do
        if [ -e "${file}" ]; then
            ./LightUploader -c config.json -f "${file}" -r "public/chrome-extensions/"
        fi
    done
}

function download_crx() {
    # https://github.com/NicKoehler/chrome-crx-downloader

    # assigning the user input to url
    if [ -z $1 ]; then
        read -p "Insert the chrome extension link > " url
    else
        url=$1
    fi

    # assigning crx_name and crx_id using grep and rexex
    crx_name="$(echo $url | grep -oP '(?<=https:\/\/chrome\.google\.com\/webstore\/detail\/).+(?=\/)')"
    crx_id="$(echo $url | grep -oP '(?<=https:\/\/chrome\.google\.com\/webstore\/detail\/'${crx_name}'\/)[A-z-0-9]+')"

    # if the variables exist download the file else echo "Invalid URL"
    if !( [ -z ${crx_name} ] || [ -z ${crx_id} ] ); then

        echo -e "${Info} 开始下载 ${crx_name} 扩展 ..."
        file_url="https://clients2.google.com/service/update2/crx?response=redirect"
        file_url="${file_url}&os=linux"
        file_url="${file_url}&arch=x86-64"
        file_url="${file_url}&nacl_arch=x86-64"
        file_url="${file_url}&prod=chromiumcrx"
        file_url="${file_url}&prodchannel=unknown"
        file_url="${file_url}&prodversion=93.0.4577.82"
        file_url="${file_url}&acceptformat=crx2,crx3"
        file_url="${file_url}&x=id%3D${crx_id}"
        file_url="${file_url}%26uc"
        wget --user-agent=${user_agent} --quiet --content-disposition --check-certificate=quiet "${file_url}"

        # rename crx file
        file_oldname=$(ls extension*.crx)
        file_newname=$(echo "${file_oldname}" | sed "s/_/\./g;s/extension./${crx_name}_${crx_id}_v/g")
        mv "${file_oldname}" "${file_newname}"

        # checking if crx file exist
        if [ -s "${file_newname}" ]; then
            echo -e "${Info} ${crx_name} 扩展下载成功 !"
        else
            echo -e "${Error} ${crx_name} 扩展下载失败 !" && exit 1
        fi
    else
        echo "Invalid URL."
    fi
}

function download_crxs() {
    crx_urls=("https://chrome.google.com/webstore/detail/aria2-for-chrome/mpkodccbngfoacfalldjimigbofkhgjn"
        "https://chrome.google.com/webstore/detail/idm-integration-module/ngpampappnmepgilojfohadhhmbhlaek"
        "https://chrome.google.com/webstore/detail/infinity-new-tab-pro/nnnkddnnlpamobajfibfdgfnbcnkgngh"
        "https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif"
        "https://chrome.google.com/webstore/detail/refined-github/hlepfoohegkhhmjieoechaddaejaokhf"
        "https://chrome.google.com/webstore/detail/沙拉查词-聚合词典划词翻译/cdonnmffkdaoajfknoeeecmchibpmkmg"
        "https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo"
        "https://chrome.google.com/webstore/detail/ublock-origin/cjpalhdlnbpafiamejdnhcphjbkeiagm"
        "https://chrome.google.com/webstore/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag"
        "https://chrome.google.com/webstore/detail/划词翻译/ikhdkkncnoglghljlkmcimlnlhkeamad"
        "https://chrome.google.com/webstore/detail/集装箱/kbgigmcnifmaklccibmlepmahpfdhjch")

    for crx_url in ${crx_urls[@]}; do
        download_crx ${crx_url}
    done
}


echo -e "====== ${datetime} ======"
download_crxs
upload_crx
clean_file
