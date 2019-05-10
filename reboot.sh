#!/bin/bash
# o2box reboot script

# 1. get token from response
token=`curl -i -s -k  -X $'GET' -H $'User-Agent: Mozilla/5.0' -H $'DNT: 1' -H $'Upgrade-Insecure-Requests: 1' -b $'defpg=; popup=1' $'http://192.168.0.1/' | grep data:image | cut -d"7" -f2 | cut -d"\"" -f1 | base64 --decode`

#curl -i -s -k  -X $'GET' -H $'User-Agent: Mozilla/5.0' -H $'DNT: 1' -H $'Upgrade-Insecure-Requests: 1' -b $'defpg=; popup=1' $'http://192.168.0.1/'
#| grep data:image | cut -d"7" -f2 | cut -d"\"" -f1 | base64 --decode`

echo "[*] got token: $token"
timestamp=`date +%s`00
echo "[*] timestamp is $timestamp"

# 2. request to cgi_wizard.js
echo "[*] response from cgi_wizard: "
curl -i -s -k  -X $'GET' -H $'User-Agent: Mozilla/5.0' -H $'X-Requested-With: XMLHttpRequest' -H $'X-Prototype-Version: 1.7' -H $'DNT: 1' -b $'defpg=; popup=1' "http://192.168.0.1/cgi/cgi_wizard.js?_tn=$token&_t=$timestamp" | grep HTTP/1.1
#-o /dev/null

# 3. request to cgi_migration.js
echo "[*] response from cgi_migration: "
curl -i -s -k  -X $'GET' -H $'User-Agent: Mozilla/5.0' -H $'X-Requested-With: XMLHttpRequest' -H $'X-Prototype-Version: 1.7' -H $'DNT: 1' -b $'defpg=; popup=1' "http://192.168.0.1/cgi/cgi_migration.js?_tn=$token&_t=$timestamp" | grep HTTP/1.1
#-o /dev/null

# 4. POST request to login.cgi
echo "[*] response from login.cgi: "
curl -i -s -k  -X $'POST' -H $'User-Agent: Mozilla/5.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'DNT: 1' -H $'Upgrade-Insecure-Requests: 1' -b $'defpg=; popup=1' --data-binary $'url=&pws=LONGIDLONGIDLONGIDLONGID' -c cookie.txt $'http://192.168.0.1/login.cgi' | grep HTTP/1.1
#-o /dev/null

# 5. reboot request
echo "[*] response from reboot request: "
response=`curl -i -s -k  -X $'POST' -H $'User-Agent: Mozilla/5.0' -H $'Content-Type: application/x-www-form-urlencoded' -H $'DNT: 1' -H $'Upgrade-Insecure-Requests: 1' --data-binary "action=ui_reboot&httoken=$token&submit_button=restart_wait.htm" -b cookie.txt $'http://192.168.0.1/apply_abstract.cgi' | grep HTTP/1.1`
#-b $'defpg=; popup=1' -
echo "$response"

# 6. finish
if echo "$response" | grep -q "200"; then
        echo "[*] successfully rebooted!"
else
        echo -n "[!] no positive response from reboot request."
fi
