{
  "log": {
    "level": "warn",
    "timestamp": true
  },
  "dns": {
    "servers": [
      {
        "tag": "dns-local",
        "address": "local"
      },
      {
        "tag": "dns-fakeip",
        "address": "fakeip"
      },
      {
        "tag": "dns-block",
        "address": "rcode://name_error"
      }
    ],
    "rules": [
      {
        "query_type": ["PTR", "AAAA"],
        "server": "dns-block"
      },
      {
        "domain": [
          "airwallex.cc",
          "zmlu.me"
        ],
        "server": "dns-local"
      },
      {{ ad_dns_rule }}
      {
        "query_type": [
          "A"
        ],
        "rule_set": [
          "netflix",
          "netflixip",
          "proxy"
        ],
        "server": "dns-fakeip",
        "rewrite_ttl": 1
      }
    ],
    "final": "dns-local",
    "strategy": "ipv4_only",
    "reverse_mapping": true,
    "fakeip": {
      "enabled": true,
      "inet4_range": "240.0.0.0/4"
    },
    "independent_cache": true
  },
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "inet4_address": "172.18.0.1/30",
      "auto_route": true,
      "strict_route": true,
      "inet4_route_exclude_address": [
        "10.0.0.0/8",
        "17.0.0.0/8",
        "192.168.0.0/16"
      ],
      "inet6_route_exclude_address": [
        "fc00::/7",
        "fe80::/10"
      ],
      "exclude_package": [
        {{ exclude_package }}
      ],
      "stack": "gvisor",
      "platform": {
        "http_proxy": {
          "enabled": true,
          "server": "127.0.0.1",
          "server_port": 7890,
          "bypass_domain": [
            "localhost",
            "*.local",
            "sequoia.apple.com",
            "seed-sequoia.siri.apple.com",
            "push.apple.com",
            "talk.google.com",
            "mtalk.google.com",
            "alt1-mtalk.google.com",
            "alt2-mtalk.google.com",
            "alt3-mtalk.google.com",
            "alt4-mtalk.google.com",
            "alt5-mtalk.google.com",
            "alt6-mtalk.google.com",
            "alt7-mtalk.google.com",
            "alt8-mtalk.google.com"
          ]
        }
      },
      "sniff": true,
      "sniff_override_destination": true
    },
    {
      "type": "mixed",
      "tag": "mixed-in",
      "listen": "127.0.0.1",
      "listen_port": 7890,
      "sniff": true,
      "sniff_override_destination": true
    },
    {
      "type": "direct",
      "tag": "dns-in",
      "listen": "127.0.0.1",
      "listen_port": 1053,
      "sniff": true,
      "sniff_override_destination": true
    }
  ],
  "outbounds": [
    {
      "tag": "Proxy",
      "type": "selector",
      "outbounds": [
        "h2 ({{ vps_org }})",
        "tuic ({{ vps_org }})",
        "reality ({{ vps_org }})"
      ],
      "interrupt_exist_connections": true
    },
    {
      "type": "hysteria2",
      "tag": "h2 ({{ vps_org }})",
      "server": "{{ server_ip }}",
      "server_port": {{ h2_port }},
      "obfs": {},
      "password": "{{ password }}",
      "tls": {
        "enabled": true,
        "server_name": "www.bing.com",
        "insecure": true,
        "alpn": [
          "h3"
        ]
      }
    },
    {
      "type": "tuic",
      "tag": "tuic ({{ vps_org }})",
      "server": "{{ server_ip }}",
      "server_port": {{ tuic_port }},
      "uuid": "{{ password }}",
      "password": "{{ password }}",
      "tls": {
        "enabled": true,
        "server_name": "www.bing.com",
        "insecure": true,
        "alpn": [
          "h3"
        ]
      }
    },
    {
      "type": "vless",
      "tag": "reality ({{ vps_org }})",
      "server": "{{ server_ip }}",
      "server_port": {{ reality_port }},
      "uuid": "{{ password }}",
      "flow": "",
      "tls": {
        "enabled": true,
        "utls": {
          "enabled": true,
          "fingerprint": "chrome"
        },
        "reality": {
          "enabled": true,
          "public_key": "{{ reality_pbk }}",
          "short_id": "{{ reality_sid }}"
        },
        "server_name": "www.yahoo.com",
        "insecure": true
      },
      "packet_encoding": "xudp",
      "multiplex": {
        "enabled": true,
        "protocol": "h2mux",
        "max_connections": 1,
        "min_streams": 4,
        "padding": true,
        "brutal": {
          "enabled": true,
          "up_mbps": 1024,
          "down_mbps": 1024
        }
      }
    },
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    },
    {
      "type": "dns",
      "tag": "dns-out"
    }
  ],
  "route": {
    "rules": [
      {
        "port": 22,
        "outbound": "direct"
      },
      {
        "domain": [
          "airwallex.cc",
          "zmlu.me"
        ],
        "outbound": "direct"
      },
      {
        "ip_cidr": "8.8.8.8/32",
        "outbound": "Proxy"
      },
      {{ ad_route_rule }}
      {
        "inbound": "dns-in",
        "outbound": "dns-out"
      },
      {
        "protocol": "dns",
        "port": [
          53,
          853
        ],
        "outbound": "dns-out"
      },
      {
        "protocol": "stun",
        "rule_set": [
          "proxy"
        ],
        "outbound": "Proxy"
      },
      {
        "protocol": "stun",
        "outbound": "direct"
      },
      {
        "rule_set": [
          "netflix",
          "netflixip",
          "proxy"
        ],
        "outbound": "Proxy"
      }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "netflix",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/DustinWin/ruleset_geodata@sing-box-ruleset/netflix.srs",
        "download_detour": "direct",
        "update_interval": "24h0m0s"
      },
      {
        "type": "remote",
        "tag": "netflixip",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/DustinWin/ruleset_geodata@sing-box-ruleset/netflixip.srs",
        "download_detour": "direct",
        "update_interval": "24h0m0s"
      },
      {{ ad_rule_set }}
      {
        "type": "remote",
        "tag": "proxy",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/DustinWin/ruleset_geodata@sing-box-ruleset/proxy.srs",
        "download_detour": "direct",
        "update_interval": "24h0m0s"
      }
    ],
    "final": "direct",
    "auto_detect_interface": true,
    "override_android_vpn": true
  }
}