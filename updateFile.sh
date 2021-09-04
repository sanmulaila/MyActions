#!/bin/bash -i
set -e

cur_dir=$(
    cd $(dirname $0)
    pwd
)
checkin_dir="${cur_dir}/checkin"
conf_dir="${cur_dir}/config"
jdc_dir="${cur_dir}/jd_scripts"
wget_options='-q -c -N --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=20 -t 3 --no-check-certificate -O'
user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36'
aria2c_options='--split=8 --quiet=true --max-connection-per-server=8 --retry-wait=20 --timeout=20 --check-certificate=false --allow-overwrite=true -U "${user_agent}"'
# aria2c_options='--split=8 --max-connection-per-server=8 --retry-wait=20 --timeout=20 --check-certificate=false --allow-overwrite=true --all-proxy=http://127.0.0.1:8889 -U "${user_agent}"'

function mk_dir() {
    for folder in "${checkin_dir}" "${conf_dir}" "${jdc_dir}"; do
        if [ ! -d "${folder}" ]; then
            mkdir -p "${folder}"
        fi
    done
}

function update_file() {
    sudo apt-get install -y aria2
    yarn global add pangu

    cd ${checkin_dir}/
    aria2c ${aria2c_options} -o 'netease.py' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/py/netease.py'
    aria2c ${aria2c_options} -o 'mimotion.py' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/py/mimotion.py'
    aria2c ${aria2c_options} -o 'check.multiple.simple.json' 'https://raw.githubusercontent.com/Oreomeow/checkinpanel/master/check.multiple.json'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/checksendNotify.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_bilibili.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_cloud189.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_csdn.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_mimotion.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_music163.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_pojie.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_smzdm.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_tieba.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_v2ex.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_womail.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/ck_youdao.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/getENV.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/motto.py'
    aria2c ${aria2c_options} 'http://raw.githubusercontent.com/Oreomeow/checkinpanel/master/weather.py'
    pangu -f check.multiple.simple.json >>check.multiple.simple_1.json
    ls *.* | awk -F "_1" '{print "mv -f "$0" "$1$2""}' | bash

    cd ${conf_dir}/
    aria2c ${aria2c_options} -o 'checkcookie.sh' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/sh/Helpcode2.8/checkcookie.sh'
    aria2c ${aria2c_options} -o 'task_before.sh' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/sh/Helpcode2.8/task_before.sh'
    aria2c ${aria2c_options} -o 'config.sample.sh' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Conf/Qinglong/config.sample.sh'
    aria2c ${aria2c_options} -o 'code.sample.sh' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/sh/Helpcode2.8/code.sh'
    aria2c ${aria2c_options} -o 'extra.sample.sh' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Tasks/qlrepo/extra.sh'
    aria2c ${aria2c_options} -o 'config.template.json' 'https://gitee.com/sitoi/dailycheckin/raw/main/docker/config.template.json'
    aria2c ${aria2c_options} -o 'Usage.txt' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/sh/Helpcode2.8/Usage.txt'
    aria2c ${aria2c_options} -o 'doc.txt' 'https://raw.githubusercontent.com/Oreomeow/VIP/main/Scripts/sh/Helpcode2.8/doc.txt'
    pangu -f code.sample.sh >>code.sample_1.sh
    pangu -f extra.sample.sh >>extra.sample_1.sh
    pangu -f config.sample.sh >>config.sample_1.sh
    pangu -f config.template.json >>config.template_1.json
    ls *.* | awk -F "_1" '{print "mv -f "$0" "$1$2""}' | bash

    cd ${jdc_dir}/
    aria2c ${aria2c_options} -o 'gua_wealth_island_help.js' 'https://raw.githubusercontent.com/smiek2221/scripts/master/gua_wealth_island_help.js'
    aria2c ${aria2c_options} -o 'gua_wealth_island.js' 'https://raw.githubusercontent.com/jiulan/platypus/main/scripts/jd_cfd_new.js'
    aria2c ${aria2c_options} -o 'jd_all_bean_change.js' 'https://raw.githubusercontent.com/jiulan/platypus/main/scripts/jd_all_bean_change.js'
    aria2c ${aria2c_options} -o 'jd_bean_change_new.js' 'https://raw.githubusercontent.com/shufflewzc/faker2/main/jd_bean_change_new.js'
    aria2c ${aria2c_options} -o 'jd_bean_change.js' 'https://raw.githubusercontent.com/yuannian1112/jd_scripts/main/jd_bean_change.js'
    aria2c ${aria2c_options} -o 'star_dreamFactory_tuan.js' 'https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/jd_ccSign.js'
    aria2c ${aria2c_options} -o 'jd_dreamFactory_tuan.js' 'https://raw.githubusercontent.com/star261/jd/main/scripts/star_dreamFactory_tuan.js'
    aria2c ${aria2c_options} -o 'jd_jxlhb.js' 'https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/jd_jxlhb.js'
    aria2c ${aria2c_options} -o 'jd_jxmc.js' 'https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/jd_jxmc.js'
    aria2c ${aria2c_options} -o 'jd_redPacket.js' 'https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/jd_redPacket.js'
    aria2c ${aria2c_options} -o 'package.json' 'https://raw.githubusercontent.com/shufflewzc/faker2/main/package.json'
    aria2c ${aria2c_options} -o 'USER_AGENTS.js' 'https://raw.githubusercontent.com/yuannian1112/jd_scripts/main/USER_AGENTS.js'
    aria2c ${aria2c_options} -o 'jx_sign.js' 'https://raw.githubusercontent.com/Aaron-lv/sync/jd_scripts/jx_sign.js'
    sed -e 's|"undefined"!=typeof process&&JSON.stringify(process.env).indexOf("GITHUB")>-1&&process.exit(0);||g' -i *.js
    sed -e "/if (JSON.stringify(process.env).indexOf('GITHUB') > -1) process.exit(0);/d" -i jd_redPacket.js
    sed -e 's|const HelpAuthorFlag = true|const HelpAuthorFlag = false|g' -i gua_wealth_island.js
    sed -e 's|let buildLvlUp = true|let buildLvlUp = false|g' -i gua_wealth_island.js
}

mk_dir
update_file
