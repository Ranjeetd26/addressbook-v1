sudo yum install git -y
sudo yum install docker -y
sudo systemctl start docker

if [ -d "addressbook-v1" ]
then
  echo "repo is cloned and exists"
  cd /home/ec2-user/addressbook-v1
  git pull origin master
else
  git clone https://github.com/Ranjeetd26/addressbook-v1.git
fi

cd /home/ec2-user/addressbook-v1
git checkout master 
# mvn compile
sudo docker build -t $1 .