#!/bin/bash -i
set -euxo pipefail

cur_dir=$(
    cd $(dirname $0)
    pwd
)
checkin_dir="${cur_dir}/checkin"
env_file="${checkin_dir}/env.sh"
check_config_file="${checkin_dir}/check.json"

cd ${checkin_dir}
touch ${env_file}
python3 -m pip install cryptography~=3.2.1 requests rsa
echo "${CHECK_JSON}" >"${check_config_file}"
sed -e "s|/ql/config/env.sh|${env_file}|g" -i getENV.py
sed -e "s|/ql/config/check.json|${check_config_file}|g" -i getENV.py

sleep 10 && python3 ck_bilibili.py
sleep 10 && python3 ck_cloud189.py
sleep 10 && python3 ck_csdn.py
sleep 10 && python3 ck_mimotion.py
sleep 10 && python3 ck_music163.py
sleep 10 && python3 ck_pojie.py
sleep 10 && python3 ck_smzdm.py
sleep 10 && python3 ck_tieba.py
sleep 10 && python3 ck_v2ex.py
# sleep 10 && python3 ck_womail.py
sleep 10 && python3 ck_youdao.py
# sleep 10 && python3 mimotion.py
sleep 10 && python3 motto.py
# sleep 10 && python3 netease.py
sleep 10 && python3 weather.py
