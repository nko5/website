set -evu

# Creating the deploy key...
ssh-keygen -t rsa -b 2048 -P '' -f ~/.ssh/id_deploy

# Authorizing the deploy key for ssh access...
cat ~/.ssh/id_deploy.pub >> ~/.ssh/authorized_keys
