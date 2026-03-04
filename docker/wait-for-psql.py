#!/bin/bash
"""
Wait for PostgreSQL to be ready
This script is used by Docker entrypoint to ensure DB is running before Odoo starts
"""

import argparse
import psycopg2
import sys
import time

def wait_for_postgres(host, port, user, password, timeout):
    """Wait for PostgreSQL to accept connections"""
    start_time = time.time()
    
    while True:
        try:
            conn = psycopg2.connect(
                host=host,
                port=port,
                user=user,
                password=password,
                dbname='postgres'
            )
            conn.close()
            print(f"✅ PostgreSQL is ready! ({host}:{port})")
            return True
        except psycopg2.OperationalError:
            elapsed = time.time() - start_time
            if elapsed > timeout:
                print(f"❌ PostgreSQL not available after {timeout}s")
                sys.exit(1)
            print(f"⏳ Waiting for PostgreSQL... ({int(elapsed)}s)")
            time.sleep(1)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Wait for PostgreSQL')
    parser.add_argument('--db-host', default='db')
    parser.add_argument('--db-port', type=int, default=5432)
    parser.add_argument('--db-user', default='odoo')
    parser.add_argument('--db-password', default='odoo')
    parser.add_argument('--timeout', type=int, default=30)
    
    args = parser.parse_args()
    
    wait_for_postgres(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_password,
        timeout=args.timeout
    )
