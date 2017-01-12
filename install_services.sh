#!/bin/bash
input=$1
# Set "," as the field separator using $IFS 
# and read line by line using while read combo 

read -s -p "Enter solution user's Password: " bd_passwd

prep_node(){
	server=$1
	bd_user=$2
	service_name=$3
	ssh $server "bash -s" < bigtop-node/install.sh $bd_user $bd_passwd
	# copy scripts
	scp -r $service_name $server:~/.
	scp common/* $server:~/$service
}

install_service(){
bd_user=$3
bd_ip=$2
#server=$bd_user@$bd_ip
server=root@$bd_ip
service_name=$1
namenode=$4
resourcemanager=$5

prep_node $server $bd_user $service_name
ssh $server "$service_name/install.sh $bd_user $bd_passwd" < /dev/null
ssh -t $server "$service_name/config.sh $namenode $resourcemanager $bd_user $bd_passwd" < /dev/null
ssh $server "$service_name/start.sh $bd_user $bd_passwd" < /dev/null
}

while IFS=',' read -r f1 f2 f3 f4 f5 f6 f7
do 
  ## Ignore lines start with "#"
  case $f1 in
        \#*) continue;;
  esac
  echo "Service Name="$f1
  echo "  Service Location="$f2
  echo "  Service User Name="$f3
  echo "  NameNode hostname="$f4
 echo "  ResourceManager hostname="$f5
install_service $f1 $f2 $f3 $f4 $f5
done < "$input"

