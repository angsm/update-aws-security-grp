#!/bin/bash
# Shell Script to Update AWS EC2 Security Groups

# CONFIG - Only edit the below lines to setup the script
# ===============================

# AWS Profile Name
profile="default"

# Groups, separated with spaces
group_ids="sg-xxx sg-yyy"

# Fixed IPs, separated with spaces
fixed_ips="1.1.1.1/32 2.2.2.2/32";

# Port
port=22;

# ===============================

for group_id in $group_ids
do

    # Display group name
    echo -e "\033[34m\nModifying Group: ${group_id}\033[0m";

    # Get existing IP rules for group
    ips=$(aws ec2 --profile=$profile describe-security-groups --filters Name=ip-permission.to-port,Values=$port Name=ip-permission.from-port,Values=$port Name=ip-permission.protocol,Values=tcp --group-ids $group_id --output text --query 'SecurityGroups[*].{IP:IpPermissions[?ToPort==`'$port'`].IpRanges}' | sed 's/IP	//g');

    # Loop through IPs
    for ip in $ips
    do
        echo -e "\033[31mRemoving IP: $ip\033[0m"

        # Delete IP rules matching port
        aws ec2 revoke-security-group-ingress --profile=$profile --group-id $group_id --protocol tcp --port $port --cidr $ip
    done

    # Get current public IP address
    ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1);
    ip6=$(/sbin/ip -o -6 addr list eth0 | awk '{print $4}' | cut -d/ -f1);

    echo -e "\033[32mSetting Current IP: ${ip4}\033[0m"

    # Add current IP as new rule
    aws ec2 authorize-security-group-ingress --profile=$profile --protocol tcp --port $port --cidr ${ip4}/32 --group-id $group_id

    # Loop through fixed IPs
    for ip in $fixed_ips
    do
        echo -e "\033[32mSetting Fixed IP: ${ip}\033[0m"

        # Add fixed IP rules
        aws ec2 authorize-security-group-ingress --profile=$profile --protocol tcp --port $port --cidr ${ip} --group-id $group_id
    done

done
