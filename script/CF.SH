#!/bin/bash
# based on https://gist.github.com/Tras2/cba88201b17d765ec065ccbedfb16d9a
# initial data; they need to be filled by the user
## API token; e.g. FErsdfklw3er59dUlDce44-3D43dsfs3sddsFoD3
api_token=<YOUR_API_TOKEN>
## the email address associated with the Cloudflare account; e.g. email@gmail.com
email=<YOUR_EMAIL>
## the zone (domain) should be modified; e.g. example.com
zone_name=<YOUR_DOMAIN>
## the dns record (sub-domain) should be modified; e.g. sub.example.com
dns_record=<YOUR_SUB_DOMAIN>

# Check if already running
if ps ax | grep $0 | grep -v $$ | grep bash | grep -v grep; then
   echo -e "\033[0;31m [-] The script is already running."
   exit 1
fi

# Check jq installed
check_jq=$(which jq)
if [ -z "${check_jq}" ]; then
   echo -e "\033[0;31m [-] jq not installed. jq must be created first!"
   exit
fi

# Check DNS Records Exists
check_record_ipv4=$(dig -t a +short ${dns_record} | tail -n1)
check_record_ipv6=$(dig -t aaaa +short ${dns_record} | tail -n1)

# get the basic data
ipv4=$(curl -s -X GET -4 https://ifconfig.co)
ipv6=$(curl -s -X GET -6 https://ifconfig.co)
user_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
               -H "Authorization: Bearer $api_token" \
               -H "Content-Type:application/json" | jq -r '{"result"}[] | .id' )

# write down IPv4 and/or IPv6
if [ $ipv4 ]; then echo -e "\033[0;32m [+] Your public IPv4 address: $ipv4"; else echo -e "\033[0;33m [!] Unable to get any public IPv4 address."; fi
if [ $ipv6 ]; then echo -e "\033[0;32m [+] Your public IPv6 address: $ipv6"; else echo -e "\033[0;33m [!] Unable to get any public IPv6 address."; fi

# check if the user API is valid and the email is correct
if [ $user_id ]
then
    zone_id=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name&status=active" \
                   -H "Content-Type: application/json" \
                   -H "X-Auth-Email: $email" \
                   -H "Authorization: Bearer $api_token" \
              | jq -r '{"result"}[] | .[0] | .id' )
    # check if the zone ID is avilable
    if [ $zone_id ]
    then
        # check if there is any IP version 4
        if [ $ipv4 ]
        then
           # Check A Record exists
           if [ -z "${check_record_ipv4}" ]; then
              echo -e "\033[0;31m [-] No A Record called ${dns_record}. This must be created first!"
              exit
           fi
           dns_record_a_id=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$dns_record"  \
                                   -H "Content-Type: application/json" \
                                   -H "X-Auth-Email: $email" \
                                   -H "Authorization: Bearer $api_token" )
            # if the IPv4 exist
            dns_record_a_ip=$(echo $dns_record_a_id |  jq -r '{"result"}[] | .[0] | .content')
            if [ $dns_record_a_ip != $ipv4 ]
            then
                # change the A record
                curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$(echo $dns_record_a_id | jq -r '{"result"}[] | .[0] | .id')" \
                     -H "Content-Type: application/json" \
                     -H "X-Auth-Email: $email" \
                     -H "Authorization: Bearer $api_token" \
                     --data "{\"type\":\"A\",\"name\":\"$dns_record\",\"content\":\"$ipv4\",\"ttl\":1,\"proxied\":false}" | jq -r '.errors'
                # write the result
                echo -e "\033[0;32m [+] Updated: The IPv4 is successfully set on Cloudflare as the A Record with the value of: $dns_record_a_ip"
            else
                echo -e "\033[0;37m [~] No change: The current IPv4 address matches Cloudflare"
            fi
        fi
            
        # check if there is any IP version 6
        if [ $ipv6 ]
        then
          .# Check A Record exists
          if [ -z "${check_record_ipv6}" ]; then
             echo -e "\033[0;31m [-] No AAAA Record called ${dns_record}. This must be created first!"
             exit
          fi
          dns_record_aaaa_id=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=AAAA&name=$dns_record"  \
                                    -H "Content-Type: application/json" \
                                    -H "X-Auth-Email: $email" \
                                    -H "Authorization: Bearer $api_token" )
           # if the IPv6 exist
           dns_record_aaaa_ip=$(echo $dns_record_aaaa_id | jq -r '{"result"}[] | .[0] | .content')
           if [ $dns_record_aaaa_ip != $ipv6 ]
           then
           # change the AAAA record
             N curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$(echo $dns_record_aaaa_id | jq -r '{"result"}[] | .[0] | .id')" \
                     -H "Content-Type: application/json" \
                     -H "X-Auth-Email: $email" \
                     -H "Authorization: Bearer $api_token" \
                     --data "{\"type\":\"AAAA\",\"name\":\"$dns_record\",\"content\":\"$ipv6\",\"ttl\":1,\"proxied\":false}" | jq -r '.errors'
                # write the result
                echo -e "\033[0;32m [+] Updated: The IPv6 is successfully set on Cloudflare as the AAAA Record with the value of: $dns_record_aaaa_ip"
            else
                echo -e "\033[0;37m [~] No change: The current IPv6 address matches Cloudflare."
            fi
        fi  
    else
        echo -e "\033[0;31m [-] There is a problem with getting the Zone ID (subdomain) or the email address (username). Check them and try again."
    fi
else
    echo -e "\033[0;31m [-] There is a problem with either the API token. Check it and try again."
fi
