#!/bin/bash
container_id=$(mktemp)
echo "creating container for ${distribution} ${version}..."
sudo docker run --detach --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro --volume="${PWD}":/etc/ansible/roles/:ro ${distribution}-${version}:ansible > "${container_id}"
echo "verifying role syntax..."
sudo docker exec "$(cat ${container_id})" env ANSIBLE_FORCE_COLOR=1 ansible-playbook -v /etc/ansible/roles/test.yml --syntax-check
echo "running the play..."
sudo docker exec "$(cat ${container_id})" env ANSIBLE_FORCE_COLOR=1 ansible-playbook -v /etc/ansible/roles/test.yml
echo "runing idempotence test..."
sudo docker exec "$(cat ${container_id})" env ANSIBLE_FORCE_COLOR=1 ansible-playbook -v /etc/ansible/roles/test.yml | grep -q 'changed=0.*failed=0' && (echo 'Idempotence test passed' && exit 0) || (echo 'Idempotence test failed' && exit 1)
echo "cleanup container..."
sudo docker rm -f "$(cat ${container_id})"
