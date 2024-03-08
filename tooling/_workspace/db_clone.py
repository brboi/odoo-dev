import sys
from argparse import ArgumentParser

import requests


def clone(options):
    cookies = {
        'frontend_lang': 'en_US',
        'tz': 'Europe/Brussels',
    }

    headers = {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Accept-Language': 'en-GB,en-US;q=0.9,en;q=0.8',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Origin': f'http://localhost:{options.port}',
        'Pragma': 'no-cache',
        'Referer': f'http://localhost:{options.port}/web/database/manager',
    }

    for i in range(options.count):
        new_name = f"{options.database}-{i}"
        data = {
            'master_pwd': 'Password',
            'name': options.database,
            'new_name': new_name,
        }
        response = requests.post(
            f'http://localhost:{options.port}/web/database/duplicate',
            cookies=cookies,
            headers=headers,
            data=data,
        )
        print(response.status_code, response.reason, f"from {options.database} to {new_name}")


def main() -> int:
    parser = ArgumentParser(
        description="db_clone :: clone a database using the odoo web interface"
    )
    parser.add_argument(
        '-d', '--database',
        help='Name of the database to clone',
        type=str,
        default='main'
    )
    parser.add_argument(
        '-c', '--count',
        help='Number of clones to create',
        type=int,
        default=1
    )
    parser.add_argument(
        '-p', '--port',
        help='Port of the odoo instance',
        type=int,
        default=8069
    )
    parser.add_argument('-mp', '--master-password',
                        help='Master Password of the odoo instance',
                        default='Password')
    options = parser.parse_args()
    clone(options)


if __name__ == "__main__":
    sys.exit(main())
