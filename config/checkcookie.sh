#!/usr/bin/env bash

## Build 20210831-001

printf "\e[?25l"
cookie_num=($(cat JDCookies.txt | wc -l))
datetime=$(date +"%Y-%m-%d %T")
str=""
bgcolor=21
space48="                                                 "

gen_pt_pin_array() {
    # local envs=$(eval echo "\$JD_COOKIE")
    # local array=($(echo $envs | sed 's/&/ /g'))
    local array=($(cat JDCookies.txt | tr "\n" " "))
    local tmp1 tmp2 i pt_pin_temp
    for i in "${!array[@]}"; do
        pt_pin_temp=$(echo ${array[i]} | perl -pe "{s|.*pt_pin=([^; ]+)(?=;?).*|\1|; s|%|\\\x|g}")
        [[ $pt_pin_temp == *\\x* ]] && pt_pin[i]=$(printf $pt_pin_temp) || pt_pin[i]=$pt_pin_temp
    done
}

check_jd_cookie() {
    local test_connect="$(curl -I -s --connect-timeout 5 https://bean.m.jd.com/bean/signIndex.action -w %{http_code} | tail -n1)"
    local test_jd_cookie="$(curl -s --noproxy "*" "https://bean.m.jd.com/bean/signIndex.action" -H "cookie: $1")"
    # local status=$(cat $dir_db/env.db | grep "$1" | perl -pe "{s|.*status\":([^,\"]).*|\1|g}" | tail -1)
    if [ "$test_connect" -eq "302" ]; then
        [[ "$test_jd_cookie" ]] && echo "(COOKIE 有效)" || echo "(COOKIE 已失效)"
    else
        echo "(API 连接失败)"
    fi
}

dump_user_info() {
    # local envs=$(eval echo "\$JD_COOKIE")
    # local array=($(echo $envs | sed 's/&/ /g'))
    local array=($(cat JDCookies.txt | tr "\n" " "))
    local notify_content=""
    echo "COOKIES: " >JDCookies1.log

    printf "===================================\n============ OldCookie {$datetime} ============\n\n===================================\n============ NewCookie {$datetime} ============\n\n" >JDCookies.log

    for ((m = 0; m < ${#pt_pin[*]}; m++)); do
        j=$((m + 1))
        if [[ $(check_jd_cookie ${array[m]}) =~ "已失效" ]]; then
            printf "用户 %2d %16b 的 Cookie 已失效 \n" $j ${pt_pin[m]} >>JDCookies1.log
            sed -i "/OldCookie/i${array[m]}" JDCookies.log
        else
            printf "用户 %2d %16b 的 Cookie 有效 ++++++++++++++++++\n" $j ${pt_pin[m]} >>JDCookies1.log
            sed -i "/NewCookie/i${array[m]}" JDCookies.log
        fi
        # echo -e "## 用户名 $j：${pt_pin[m]} 备注：${remark_name[m]} $(check_jd_cookie ${array[m]})\nCookie$j=\"${array[m]}\""

        percentstr=$(printf "%3s" $(($m * 100 / $cookie_num)))
        totalstr="${space48}${percentstr}${space48}"
        leadingstr="${totalstr:0:$(($m * 100 / $cookie_num + 1))}"
        trailingstr="${totalstr:$(($m * 100 / $cookie_num + 1))}"
        printf "\r\e[30;47m${leadingstr}\e[37;40m${trailingstr}\e[0m"
        str+="="
    done
}

gen_pt_pin_array
dump_user_info
printf "\nTime-consuming: %2d seconds" $SECONDS
printf "\e[?25h""\n"
cat JDCookies.txt | tr "\n" "&"
