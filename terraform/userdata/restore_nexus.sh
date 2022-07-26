sudo yum install unzip -y

#Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

cat <<EOT> /tmp/config
[default]
region = us-east-2
output = json
EOT

cat <<EOT> /tmp/credentials
[default]
aws_access_key_id = AKIAYIM3N2BWN24WYL75
aws_secret_access_key = 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
EOT

chmod 755 /tmp/c*
mkdir /home/ec2-user/.aws
sudo cp /tmp/c* /home/ec2-user/.aws/
sudo cp -r /home/ec2-user/.aws/ /var/lib/jenkins/

systemctl stop nexus
aws s3 cp s3://vprofile-cicd-amit-backup/nexus-cicd-vpro-pro.tgz /tmp/nexus-cicd-vpro-pro.tgz
sudo mv /tmp/nexus-cicd-vpro-pro.tgz /opt/nexus-cicd-vpro-pro.tgz
cd /opt/
sudo tar -zvxf nexus-cicd-vpro-pro.tgz

systemctl start nexus