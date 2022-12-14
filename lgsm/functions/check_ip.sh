#!/bin/bash
# LinuxGSM check_ip.sh module
# Author: Daniel Gibbs
# Contributors: http://linuxgsm.com/contrib
# Website: https://linuxgsm.com
# Description: Automatically identifies the server interface IP.
# If multiple interfaces are detected the user will need to manually set using ip="0.0.0.0".

functionselfname="$(basename "$(readlink -f "${BASH_SOURCE[0]}")")"

info_game.sh

ip_commands_array=("/bin/ip" "/usr/sbin/ip" "ip")
for ip_command in "${ip_commands_array[@]}"; do
	if [ "$(command -v ${ip_command} 2> /dev/null)" ]; then
		ipcommand="${ip_command}"
		break
	fi
done

ethtool_commands_array=("/bin/ethtool" "/usr/sbin/ethtool" "ethtool")
for ethtool_command in "${ethtool_commands_array[@]}"; do
	if [ "$(command -v ${ethtool_command} 2> /dev/null)" ]; then
		ethtoolcommand="${ethtool_command}"
		break
	fi
done

getip=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}' | sort -u | grep -v 127.0.0)
getipwc=$(${ipcommand} -o -4 addr | awk '{print $4}' | grep -oe '\([0-9]\{1,3\}\.\?\)\{4\}' | sort -u | grep -vc 127.0.0)

# Check if server has multiple IP addresses

# If the IP variable has been set by user.
if [ -n "${ip}" ] && [ "${ip}" != "0.0.0.0" ]; then
	queryips=("${ip}")
	webadminip=("${ip}")
	telnetip=("${ip}")
# If game config does have an IP set.
elif [ -n "${configip}" ] && [ "${configip}" != "0.0.0.0" ]; then
	queryips=("${configip}")
	ip="${configip}"
	webadminip=("${configip}")
	telnetip=("${configip}")
# If there is only 1 server IP address.
# Some IP details can automaticly use the one IP
elif [ "${getipwc}" == "1" ]; then
	queryips=($(echo "${getip}"))
	ip="0.0.0.0"
	webadminip=("${getip}")
	telnetip=("${getip}")
# If no ip is set by the user and server has more than one IP.
else
	queryips=($(echo "${getip}"))
	ip="0.0.0.0"
	webadminip=("${ip}")
	telnetip=("${ip}")
fi
