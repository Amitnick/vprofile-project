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
mkdir /home/ubuntu/.aws
sudo cp /tmp/c* /home/ubuntu/.aws/
sudo cp -r /home/ubuntu/.aws/ /var/lib/jenkins/

#Install docker
sudo apt-get update
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo chmod 666 /var/run/docker.sock
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 567798517868.dkr.ecr.us-east-2.amazonaws.com

#Restore Jenkins
sudo systemctl stop jenkins
aws s3 cp s3://vprofile-cicd-amit-backup/jenkins_backup_cd.tar.gz /tmp/jenkins_backup_cd.tar.gz
cd /var/lib
sudo mv /tmp/jenkins_backup_cd.tar.gz ./
sudo tar -zvxf jenkins_backup_cd.tar.gz
sudo chown jenkins:jenkins -R jenkins/
sudo systemctl start jenkins

#Install Kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl