import json
import random
import re
import subprocess
import uuid
import os

def get_ip_info():
    curl_out = subprocess.check_output(['curl', '-s', '-4', 'ip.network/more'])
    data_str = curl_out.decode('utf-8')
    ip_infp = json.loads(data_str)
    server_ip = ip_infp.get('ip')
    country = ip_infp.get('country')
    vps_org = ip_infp.get('asOrganization')
    return server_ip, vps_org, country


def generate_reality_keys():
    xray_out = subprocess.check_output(['sing-box', 'generate', 'reality-keypair'])
    data_str = xray_out.decode('utf-8')
    private_key_pattern = r'PrivateKey: ([\w-]+)'
    public_key_pattern = r'PublicKey: ([\w-]+)'
    private_key_match = re.search(private_key_pattern, data_str)
    public_key_match = re.search(public_key_pattern, data_str)
    private_key = private_key_match.group(1) if private_key_match else 'wKpQJg3pYNmHIdYNfcgkOpkuDRjBu_HtT5AILoKIlnA'
    public_key = public_key_match.group(1) if public_key_match else 'IBFZzGV6xrzrXPCzFMNN3L6paUDNJNoXUbXSKjYEFG4'
    return private_key, public_key


def generate_reality_sid():
    openssl_out = subprocess.check_output(['sing-box', 'generate', 'rand', '4', '--hex'])
    data_str = openssl_out.decode('utf-8')
    data_str = ''.join(data_str.splitlines())
    return data_str


def generate_password():
    openssl_out = subprocess.check_output(['sing-box', 'generate', 'uuid'])
    data_str = openssl_out.decode('utf-8')
    data_str = ''.join(data_str.splitlines())
    return data_str


def generate_port():
    min_value = 9000
    max_value = 65535
    random_numbers = random.sample(range(min_value, max_value + 1), 4)
    h2_port = random_numbers[0]
    tuic_port = random_numbers[1]
    reality_port = random_numbers[2]
    anytls_port = random_numbers[3]
    return h2_port, tuic_port, reality_port, anytls_port


def generate_esb_config():
    server_ip, vps_org, country = get_ip_info()
    private_key, public_key = generate_reality_keys()
    reality_sid = generate_reality_sid()
    h2_port, tuic_port, reality_port, anytls_port = generate_port()
    password = generate_password()
    www_dir_random_id = ''.join(random.sample(uuid.uuid4().hex, 6))

    # print(f'server_ip: {server_ip}')
    # print(f'vps_org: {vps_org}')
    # print(f'country: {country}')
    # print(f'password: {password}')
    # print(f'h2_port: {h2_port}')
    # print(f'tuic_port: {tuic_port}')
    # print(f'reality_port: {reality_port}')
    # print(f'reality_pbk: {public_key}')
    # print(f'reality_private_key: {private_key}')
    # print(f'reality_sid: {reality_sid}')
    # print(f'anytls_port: {anytls_port}')
    # print(f'www_dir_random_id: {www_dir_random_id}')

    esb_config = {}
    esb_config['server_ip'] = server_ip
    esb_config['vps_org'] = vps_org
    esb_config['country'] = country
    esb_config['www_dir_random_id'] = www_dir_random_id
    esb_config['password'] = password
    esb_config['h2_port'] = h2_port
    esb_config['tuic_port'] = tuic_port
    esb_config['reality_port'] = reality_port
    esb_config['reality_sid'] = reality_sid
    esb_config['public_key'] = public_key
    esb_config['private_key'] = private_key
    esb_config['anytls_port'] = anytls_port

    config_file = os.path.expanduser('~/esb.config')
    with open(config_file, 'w') as write_f:
        write_f.write(json.dumps(esb_config, indent=2, ensure_ascii=False))


if __name__ == '__main__':
    generate_esb_config()
