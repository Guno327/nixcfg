#!/usr/bin/python
import http.client
import json


# Get sender ip from web
def get_ip():
    iphost = http.client.HTTPSConnection("ipapi.co")
    iphost.request("GET", "/ip/")
    respo = iphost.getresponse()
    ip_addr = respo.read()
    return ip_addr.decode("utf-8")


# Change the IP for A record
def update_a_record(heads, ip_addr, web_addr, zone, id):
    conn = http.client.HTTPSConnection("api.cloudflare.com")
    payload = (
        '{\n  "content": "%s",\n  "name": "%s",\n  "proxied": false,\n  "type": "A",\n  "comment": "Domain verification record",\n  "ttl": 3600\n}'
        % (ip_addr, web_addr)
    )
    conn.request(
        "PUT", "/client/v4/zones/%s/dns_records/%s/" % (zone, id), payload, heads
    )
    res = conn.getresponse()
    data = res.read()
    data = data.decode("utf-8")
    data = json.loads(data)


# Change the IP for PTR record
def update_ptr_record(head, ip, addr, zone, id):
    conn = http.client.HTTPSConnection("api.cloudflare.com")
    payload = (
        '{\n  "content": "%s",\n  "name": "%s",\n  "proxied": false,\n  "type": "PTR",\n  "comment": "Domain verification record",\n  "ttl": 3600\n}'
        % (addr, ip)
    )
    conn.request(
        "PUT", "/client/v4/zones/%s/dns_records/%s/" % (zone, id), payload, head
    )
    res = conn.getresponse()
    data = res.read()
    data = data.decode("utf-8")
    data = json.loads(data)


# Generate PTR ip from ip
def ptr_ip(ip):
    result = ""
    working = ""
    for c in reversed(ip):
        if c == ".":
            result += working
            result += "."
            working = ""
        else:
            working = c + working

    result += working + ".in-addr.arpa.ghov.net"
    return result


# Address and other api info
addr = "ghov.net"
zone_id = "9249ad5939000723023cbfe532542eb0"
api_key = "vvZoI9Wnpm6ftJVi9bk23d70TP6-EXK-KDeFQm05"
headers = {"Content-Type": "application/json", "Authorization": "Bearer %s" % (api_key)}

ip = get_ip()

# Get all records
cfhost = http.client.HTTPSConnection("api.cloudflare.com")
cfhost.request("GET", "/client/v4/zones/%s/dns_records" % zone_id, headers=headers)
records = json.loads(cfhost.getresponse().read().decode("utf-8"))

# Traverse records
changed = False
for record in records["result"]:
    # Update A records
    if record["type"] == "A":
        if record["content"] != ip:
            update_a_record(headers, ip, record["name"], zone_id, record["id"])
            print(
                f'Updated A record "{record['name']}" from {record['content']} to {ip}'
            )
            changed = True

    # Update PTR record
    if record["type"] == "PTR":
        p_ip = ptr_ip(ip)
        if record["name"] != p_ip:
            update_ptr_record(headers, p_ip, record["content"], zone_id, record["id"])
            print(
                f'Updated PTR record "{record['content']}" from {record['name']} to {ptr_ip(ip)}'
            )
            changed = True

if not changed:
    print("No records need updating")
