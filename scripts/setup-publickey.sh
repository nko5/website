set -evu

# Creating public/private keypair for the box...
ssh-keygen -t rsa -b 2048 -P '' -f ~/.ssh/id_rsa

# Authorizing the box public key for ssh access...
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
