# -*- coding: utf-8 -*-
"""
cron: 30 10 * * *
new Env('CSDN');
"""

import json, os, requests
from getENV import getdata
from checksendNotify import send


class CSDNCheckIn:
    def __init__(self, csdn_cookie_list):
        self.csdn_cookie_list = csdn_cookie_list
        self.headers = {
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_2_2) AppleWebKit/537.36 (KHTML, like Gecko) "
                          "Chrome/88.0.4324.182 Safari/537.36 Edg/88.0.705.74",
        }

    def sign(self, cookies):
        response = requests.get(
            url="https://me.csdn.net/api/LuckyDraw_v2/signIn", headers=self.headers, cookies=cookies
        ).json()
        if response.get("code") == 200:
            msg = response.get("data").get("msg")
        else:
            msg = "签到失败"
            print(response)
        return msg

    def draw(self, cookies):
        response = requests.get(
            url="https://me.csdn.net/api/LuckyDraw_v2/goodluck", headers=self.headers, cookies=cookies
        ).json()
        if response.get("code") == 200:
            msg = response.get("data").get("msg")
        else:
            msg = "抽奖失败"
        return msg

    def main(self):
        msg_all = ""
        for csdn_cookie in self.csdn_cookie_list:
            csdn_cookie = {
                item.split("=")[0]: item.split("=")[1] for item in csdn_cookie.get("csdn_cookie").split("; ")
            }
            try:
                user_name = csdn_cookie.get("UserName", "")
            except Exception as e:
                print(f"获取用户信息失败: {e}")
                user_name = "未获取到用户信息"
            sign_msg = self.sign(cookies=csdn_cookie)
            draw_msg = self.draw(cookies=csdn_cookie)
            msg = f"帐号信息: {user_name}\n签到信息: {sign_msg}\n抽奖结果: {draw_msg}"
            msg_all += msg + '\n\n'
        return msg_all


if __name__ == "__main__":
    data = getdata()
    _csdn_cookie_list = data.get("CSDN_COOKIE_LIST", [])
    res = CSDNCheckIn(csdn_cookie_list=_csdn_cookie_list).main()
    print(res)
    send("CSDN", res)