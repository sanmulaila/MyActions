#!/bin/bash
PATH="/usr/local/bin:/usr/bin:/bin"
# set -euxo pipefail

gh secret set JD_COOKIE <config/JDCookies1.txt
gh secret set JD_COOKIE1 <config/JDCookies.txt
gh secret set JD_COOKIE3 <config/JDCookies1.txt
gh secret set CHECK_JSON <checkin/check.json
