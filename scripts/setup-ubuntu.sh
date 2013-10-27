set -evu

# Updating apt packages...
apt-get update

# Installing git...
apt-get install -y git-core

# Installing node...
apt-get install -y python-software-properties python g++ make
add-apt-repository -y ppa:chris-lea/node.js
apt-get install -y nodejs

# Setting NODE_ENV=production...
echo "export NODE_ENV=production" > /etc/profile.d/NODE_ENV.sh

# Setting up the root user .ssh/ dir...
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys ~/.ssh/known_hosts
chmod 600 ~/.ssh/authorized_keys ~/.ssh/known_hosts

# Authorizing the nko4 public key for ssh access...
cat <<EOS >> ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAu793tQ+5RP8uo9X0WRZituBPZwRgMLxyZf+4MlM2BXxizjSlUtP/gTOHTqkzlimR1r3QOTfJN9dzs6DJZsI9T6gxJB2icjYgmYn5/4lwbry0vgoWNXwqrDkWuuSy/zaQYbbZhF3wGnqwsjR3U96XYNB6hz/ugMDkFF3BLcXvqSj0oY7FN6vdWt7tQ9y4kjkFfWJNXewshxJs8DNXqbolGqo+jvXrbq+Uj2faPKUO9rijZzmaNdKW7CX3PQl0JFWFqefKhQlyCQMoBZ47zcU79jfhYrCfd7+DIDPYAxERotGn8T+qKZbmbWPXFJ5xnFfmI6AYpBtMFeWnGol5B/CNJw== nko4
EOS

# Adding github.com to ~/.ssh/known_hosts...
cat <<EOS >> ~/.ssh/known_hosts
github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOS

# Setting up the node user...
useradd -U -m -s /bin/bash node

# Setting up the node user .ssh/ dir...
cp -r ~/.ssh /home/node/.ssh
chown -R node /home/node/.ssh

# Setting up runit...
apt-get install -y runit

# Setting runit to run server.js...
mkdir -p /etc/service/node
pushd /etc/service/node
cat <<'EOS' > ./run
#!/bin/sh
DEPLOY_DIR=/home/node/deploy
exec node $DEPLOY_DIR/current/server.js >> $DEPLOY_DIR/shared/logs/server.log 2>&1
EOS
chmod +x ./run
while [ ! -d ./supervise ]; do
  echo "Waiting for ./supervise to be created..."
  sleep 1
done
sleep 1
chown -R node ./supervise
popd

# all done!
