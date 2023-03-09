#! /usr/bin/env bash
# setup python flask server

app_name=jenkins-scm-backend

# create server user if they don't exist
if ! cat /etc/passwd | awk -F: '{ print $1}' | grep ${app_name}; then
    sudo useradd -m -s /bin/bash ${app_name}
fi

# make sure python, pip and virtualenv are installed
sudo apt install -y python3 python3-pip
sudo pip3 install virtualenv

# configure systemd service
service_environment=(
    "s/{{MYSQL_HOST}}/${MYSQL_HOST}/g;"
    "s/{{MYSQL_DATABASE}}/${MYSQL_DATABASE}/g;" 
    "s/{{MYSQL_USER}}/${MYSQL_USER}/g;" 
    "s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/g;" 
)
sed  "$(IFS=; echo "${service_environment[*]}")" ${app_name}.service | sudo tee /etc/systemd/system/${app_name}.service

# install folder
install_folder=/opt/bookshelve-server
sudo mkdir -p ${install_folder}
sudo cp -r . ${install_folder}
sudo chown -R ${app_name}:${app_name} ${install_folder}

# install dependencies
cd ${install_folder}
sudo su ${app_name} << EOF
virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
EOF

sudo systemctl daemon-reload
sudo systemctl restart ${app_name}