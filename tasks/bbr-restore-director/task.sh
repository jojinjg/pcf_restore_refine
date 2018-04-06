#!/bin/bash
. "$(dirname $0)"/../../scripts/export-director-metadata

## extract the s3 bucket contents
cd ../../../director-backup-bucket
cp -r director-*.tar ../binary/
cd ../binary/
tar -xvf director-*.tar

## the restoration of bosh director
#./bbr director --private-key-path <(echo "${BBR_PRIVATE_KEY}") --username bbr --host "${BOSH_ADDRESS}" restore --artifact-path 10.0.*

#sleep 120

echo $OPSMAN_KEY  | sed -e 's/\(KEY-----\)\s/\1\n/g; s/\s\(-----END\)/\n\1/g' | sed -e '2s/\s\+/\n/g' > ~/ssh_access.pem
chmod 600 ~/ssh_access.pem
ssh-agent > ~/agent
eval $(ssh-agent -s)
ssh-add ~/ssh_access.pem


#login to opsman
ssh -i ~/ssh_access.pem -o "StrictHostKeyChecking no"  "${OPSMAN_USER_EC2}"@"${OPSMAN_IP}" <<EOF
cd /var/tempest/workspaces/default/
ls -al
sudo bosh2 alias-env sst-director -e ${BOSH_ADDRESS} --ca-cert root_ca_certificate
BOSH_CLIENT=${BOSH_CLIENT} BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bosh2 -e sst-director --ca-cert /var/tempest/workspaces/default/root_ca_certificate login
DEPLOY_NAME ="$(BOSH_CLIENT=${BOSH_CLIENT} BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bosh2 -e sst-director --ca-cert /var/tempest/workspaces/default/root_ca_certificate deployments | head -n1 | awk '{print $1;}'"
echo "${DEPLOY_NAME}"
#BOSH_CLIENT=${BOSH_CLIENT} BOSH_CLIENT_SECRET=${BOSH_CLIENT_SECRET} bosh2 -e sst-director -d cf-965df3363954837f10b3 -n cck --resolution delete_disk_reference --resolution delete_vm_reference
EOF

##apply changes to ERT
echo "Applying changes to ERT"
#om_cmd apply-changes --ignore-warnings
#om -k --target "${OPSMAN_URL}" --username "${OPSMAN_USERNAME}" --password "${OPSMAN_PASSWORD}" apply-changes --ignore-warnings




