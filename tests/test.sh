#!/bin/bash
set -e

vagrant up --provision

ansible-galaxy install -r requirements.yml -p ./roles --force

echo "Waiting for answer on port 22..."
while ! timeout 1 nc -z 192.168.33.38 22; do
  sleep 0.2
done

ansible-playbook -i inventory.ini test.yml

ansible-playbook -i inventory.ini test.yml \
  | grep -q 'changed=0.*failed=0' \
  && (echo 'Idempotence test: pass' && exit 0) \
  || (echo 'Idempotence test: fail' && exit 1)

echo "Waiting for Samba server answer..."
while ! timeout 1 nc -z 192.168.33.38 445; do
  sleep 0.2
done

(nc -z 192.168.33.38 445) && \
(echo 'Netcat test: pass' && exit 0) ||
(echo 'Netcat test: fail' && exit 1)

vagrant destroy
