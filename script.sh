#!/bin/sh
# AutoScript Created by Jerome Laliag <jeromelaliag@yahoo.com>
 
# Operating System : UBUNTU 16 X64
 
# Config
# SUN - NOLOAD / NOTACTIVATED SIM
# SUN - FIXPLAN
# SUN - TU200
# GLOBE - GOWATCH AND PLAY
 
# Default OpenVPN Account
# Username openvpn
# Password 0p3nvpn143
 
# Config Download Link
# http://VPSIPADDRESS/config.zip
 
# How to add openvpn user account
# useradd username
# passwd username
 
# How to delete openvpn user account
# userdel username
 
# extract ip address
IPADDRESS=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{print $1}' | head -1`
IPADD="s/ipaddresxxx/$IPADDRESS/g";
# clean repo
apt-get clean
# update repo
apt-get update
# full upgrade
apt-get -y full-upgrade
# install needs
apt-get -y install openvpn
apt-get -y install easy-rsa
apt-get -y install ufw
apt-get -y install apache2
apt-get -y install squid
apt-get -y install zip
# openvpn
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="PH"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="BTG"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="Batangas City"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="GROME"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="jeromelaliag@yahoo.com"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU="MyOrganizationalUnit"|export KEY_OU="jeromelaliag"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_NAME="EasyRSA"|export KEY_NAME="jeromelaliag"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU=jeromelaliag|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_SIZE=2048|export KEY_SIZE=1024|' /etc/openvpn/easy-rsa/vars
# create diffie-helman pem
openssl dhparam -out /etc/openvpn/dh1024.pem 1024
# create pki
cd /etc/openvpn/easy-rsa
. ./vars
./clean-all
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*
# create key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
# setting key cn
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client
cd
# copy /etc/openvpn/easy-rsa/keys/{server.crt,server.key,ca.crt} /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/ca.crt
# setting server
cat > /etc/openvpn/server.conf <<-END
port 1147
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh1024.pem
client-cert-not-required
username-as-common-name
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
server 192.168.100.0 255.255.255.0
ifconfig-pool-persist ipp.txt
persist-key
persist-tun
status openvpn-status.log
log openvpn.log
verb 0
cipher none
auth none
keepalive 1 10
reneg-sec 0
tcp-nodelay
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 1.0.0.1"
END
# create noload openvpn config
cat > /root/noload.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS 1147
persist-key
persist-tun
dev tun
bind
float
lport 110
remote-cert-tls server
verb 0
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
 
END
echo '<ca>' >> /root/noload.ovpn
cat /etc/openvpn/ca.crt >> /root/noload.ovpn
echo '</ca>' >> /root/noload.ovpn
# create fixplan openvpn config
cat > /root/fixplan.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS:1147@pg.cdn.viber.com
port 1147
persist-key
persist-tun
dev tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host pg.cdn.viber.com
http-proxy-option CUSTOM-HEADER X-Online-Host pg.cdn.viber.com
http-proxy-option CUSTOM-HEADER X-Forward-Host pg.cdn.viber.com
http-proxy-option CUSTOM-HEADER Connection keep-alive
http-proxy-option CUSTOM-HEADER Proxy-Connection keep-alive
 
END
echo '<ca>' >> /root/fixplan.ovpn
cat /etc/openvpn/ca.crt >> /root/fixplan.ovpn
echo '</ca>' >> /root/fixplan.ovpn
# create tu200 openvpn config
cat > /root/tu200.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS:1147@line.telegram.me
port 1147
persist-key
persist-tun
dev tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host line.telegram.me
http-proxy-option CUSTOM-HEADER X-Online-Host line.telegram.me
http-proxy-option CUSTOM-HEADER X-Forward-Host line.telegram.me
http-proxy-option CUSTOM-HEADER Connection keep-alive
http-proxy-option CUSTOM-HEADER Proxy-Connection keep-alive
 
END
echo '<ca>' >> /root/tu200.ovpn
cat /etc/openvpn/ca.crt >> /root/tu200.ovpn
echo '</ca>' >> /root/tu200.ovpn
# create gowatch openvpn config
cat > /root/gowatch.ovpn <<-END
client
dev tun
proto tcp-client
remote $IPADDRESS:1147@www.googleapis.com
port 1147
persist-key
persist-tun
dev tun
remote-cert-tls server
verb 3
auth-user-pass
redirect-gateway def1
cipher none
auth none
auth-nocache
auth-retry interact
connect-retry 0 1
nice -20
reneg-sec 0
http-proxy $IPADDRESS 8080
http-proxy-option CUSTOM-HEADER CONNECT HTTP/1.0
http-proxy-option CUSTOM-HEADER Host www.googleapis.com
http-proxy-option CUSTOM-HEADER X-Online-Host www.googleapis.com
http-proxy-option CUSTOM-HEADER X-Forward-Host www.googleapis.com
http-proxy-option CUSTOM-HEADER Connection keep-alive
http-proxy-option CUSTOM-HEADER Proxy-Connection keep-alive
 
END
echo '<ca>' >> /root/gowatch.ovpn
cat /etc/openvpn/ca.crt >> /root/gowatch.ovpn
echo '</ca>' >> /root/gowatch.ovpn
# setting iptables
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source ipaddresxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.100.0/24 -o eth0 -j MASQUERADE
-A POSTROUTING -s 10.1.0.0/24 -o eth0 -j MASQUERADE
COMMIT
 
*filter
:INPUT ACCEPT [19406:27313311]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [9393:434129]
:fail2ban-ssh - [0:0]
-A FORWARD -i eth0 -o ppp0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i ppp0 -o eth0 -j ACCEPT
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 1147  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 1147  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8080  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8080  -m state --state NEW -j ACCEPT
COMMIT
 
*raw
:PREROUTING ACCEPT [158575:227800758]
:OUTPUT ACCEPT [46145:2312668]
COMMIT
 
*mangle
:PREROUTING ACCEPT [158575:227800758]
:INPUT ACCEPT [158575:227800758]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [46145:2312668]
:POSTROUTING ACCEPT [46145:2312668]
COMMIT
END
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local
sed -i $IPADD /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules
# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
# add dns server ipv4
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
sed -i '$ i\echo "nameserver 1.1.1.1" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 1.0.0.1" >> /etc/resolv.conf' /etc/rc.local
sed -i '$ i\sleep 10' /etc/rc.local
sed -i '$ i\for p in $(pgrep openvpn); do renice -n -20 -p $p; done' /etc/rc.local
# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Manila /etc/localtime
# setting ufw
ufw allow ssh
ufw allow 1147/tcp
sed -i 's|DEFAULT_INPUT_POLICY="DROP"|DEFAULT_INPUT_POLICY="ACCEPT"|' /etc/default/ufw
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|' /etc/default/ufw
cat > /etc/ufw/before.rules <<-END
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0]
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
END
ufw enable
ufw status
ufw disable
# set ipv4 forward
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
# restart apps
service openvpn stop
service openvpn start
# tcp tweaks
echo "fs.file-max = 51200" >> /etc/sysctl.conf
echo "net.core.rmem_max = 67108864" >> /etc/sysctl.conf
echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 250000" >> /etc/sysctl.conf
echo "net.core.somaxconn = 4096" >> /etc/sysctl.conf
echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_reuse = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 0" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_time = 1200" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 10000 65000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 8192" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_tw_buckets = 5000" >> /etc/sysctl.conf
echo "net.ipv4.tcp_fastopen = 3" >> /etc/sysctl.conf
echo "net.ipv4.tcp_mem = 25600 51200 102400" >> /etc/sysctl.conf
echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf
echo "net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control = hybla" >> /etc/sysctl.conf
# configure squid
cat > /etc/squid/squid.conf <<-END
acl localhost src 127.0.0.1/32 ::1
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32 ::1
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
acl SSH dst ipaddresxxx-ipaddresxxx/32
http_access allow SSH
http_access allow manager localhost
http_access deny manager
http_access allow localhost
http_access deny all
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern ^ftp: 1440 20% 10080
refresh_pattern ^gopher: 1440 0% 1440
refresh_pattern -i (/cgi-bin/|\?) 0 0% 0
refresh_pattern . 0 20% 4320
visible_hostname jeromelaliag
END
sed -i $IPADD /etc/squid/squid.conf;
# Add openvpn user
useradd openvpn
echo "openvpn:0p3nvpn143" | chpasswd
cd /root/
zip /var/www/html/config.zip tu200.ovpn fixplan.ovpn noload.ovpn gowatch.ovpn
reboot