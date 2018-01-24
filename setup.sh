#! /bin/sh
while getopts i:a:b:o: option
do
  case "${option}"
  in
  i) IP=${OPTARG};;
  a) ADDRESS=${OPTARG};;
  b) BOOTSTRAP=${OPTARG};;
  o) ORGNAME=${OPTARG};;
  esac
done

# If no options are provided, query user for parameters.
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    echo Enter your public IP or domain:
	read IP
	while [ -z ${IP} ]; do
	     read IP
	done
	echo Enter your wallet address::
	read ADDRESS
	echo Is tihis main node y/N:
	read BOOTSTRAP
	if [ "$BOOTSTRAP" = "Y" ] || [ "$BOOTSTRAP" = "y" ]
	  then
	    echo Enter organization name:
	    read ORGNAME
	    while [ -z ${ORGNAME} ]; do
		  read ORGNAME
		done
	fi
	echo $IP
	echo $ADDRESS
	echo $BOOTSTRAP
	echo $ORGNAME
fi
# Check for ip
if [ ! $IP  ]
  then
    echo "Server domain/IP not provided."
    exit 1
fi

# Check for user wallet address
if [ ! $ADDRESS  ]
  then
    echo "Address not provided."
    exit 1
fi

#install packages
apt-get update
apt-get install software-properties-common -y
add-apt-repository ppa:ethereum/ethereum -y
apt-get update
apt-get install ethereum -y
apt-get install solc -y
apt-get install nginx -y
apt-get install qrencode -y

# create temp wallet address
password="password"
echo $password > cache.tmp
account_address=$(geth --datadir=eth-data account new --password cache.tmp)
# Remove temp password file
rm cache.tmp
# Save account password to wallet.address file
account_address=0x$(echo $account_address | cut -d'{' -f 2| cut -d'}' -f 1)
echo $account_address > wallet.address
TEMPADDRESS=$account_address
echo 'temp wallet address is in wallet.address, password for private key is "password", the account will be empty and without function at the end of the script.'

# run bootstrap node
if [ "$BOOTSTRAP" = "Y" ] || [ "$BOOTSTRAP" = "y" ]
  then
    # Check for Organization name
	if [ ! "$ORGNAME"  ]
	  then
	    echo "No organization name (-o) provided."
	    exit 1
	fi
  	#generate random chainId and nonce
  	echo "set Bootstrap node"
	chainId=$(shuf -i 1-10000 -n 1)
	echo $chainId
	nonce=$(openssl rand -hex 6)

	# Change parameters in genesis.json file with values
	sed -i 's/XXXX/'$chainId'/g' genesis.json
	sed -i 's/ZZZZ/'$nonce'/g' genesis.json
	sed -i 's/YYYY/'2000000000000000000000000'/g' genesis.json
        sed -i 's/QQQQ/'$ADDRESS'/g' genesis.json

	# Init bootnode
	bootnode --genkey=boot.key
	key=$(bootnode --nodekey=boot.key -writeaddress)
	enode=enode://$key@$IP:30301
	echo $enode > /var/www/html/index.html
	qrencode -o /var/www/html/enode.png $enode
	cp genesis.json /var/www/html/genesis.json
	run_node="bootnode --nodekey=boot.key &"
	$run_node > /dev/null 2>&1  &
  else
  	# Get parameters for miner from server IP
	wget -q $IP/genesis.json -O genesis.json
  	echo "read enode from bootnode"
  	echo 'wget '$IP' -q -O -'
  	enode=$(wget $IP/ -q -O -)
  	echo $enode
fi
echo $enode
# Config nginx for CORS and port forwarding
cp default /etc/nginx/sites-enabled/
service nginx restart
# Start miner process
geth init genesis.json --datadir eth-data
nohup geth --datadir=eth-data --bootnodes=$enode --mine --minerthreads=1 --rpc --rpccorsdomain "*" --rpcaddr 127.0.0.1 --rpcport 7001 --etherbase=$account_address &

# run bootstrap node
if [ "$BOOTSTRAP" = "Y" ] || [ "$BOOTSTRAP" = "y" ]
  then
	echo "Waiting 20 seconds, for blockchain to establish to execute contract generation on ETH network..."
	sleep 20

	# Read contract data and move into web folder, so it is accessible by clients
	abi=$(cat bin/contracts/MotionVotingOrganisation/MotionVotingOrganisation.abi)
	data=$(cat bin/contracts/MotionVotingOrganisation/MotionVotingOrganisation.bin)
	cp bin/contracts/MotionVotingOrganisation/MotionVotingOrganisation.bin /var/www/html/MotionVotingOrganisation.bin
	cp bin/contracts/MotionVotingOrganisation/MotionVotingOrganisation.abi /var/www/html/MotionVotingOrganisation.abi

	# Check for Password
	if [ ! "$password"  ]
	  then
	    echo "Please enter your wallet password"
	    read password
	fi

	# Change parameters in generateContract.js file with values
	sed -i 's/PPPP/'$password'/g' generateContract.js
	sed -i 's/OOOO/'"$ORGNAME"'/g' generateContract.js
	sed -i 's/QQQQ/'$TEMPADDRESS'/g' generateContract.js
	sed -i 's/AAAA/'"$abi"'/g' generateContract.js
	sed -i 's/DDDD/'$data'/g' generateContract.js
	geth --exec 'loadScript("generateContract.js")' attach ipc:eth-data/geth.ipc > transaction.txt
	transactionHash=$(head -n 1 transaction.txt)

	echo "Waiting 60 seconds, for contract to be confirmed on network..."
	sleep 60
	
	# Change parameters in getContractAddressAndTransferOwnership.js file with values
	sed -i 's/PPPP/'"$password"'/g' getContractAddressAndTransferOwnership.js
	sed -i 's/QQQQ/'$TEMPADDRESS'/g' getContractAddressAndTransferOwnership.js
	sed -i 's/AAAA/'"$abi"'/g' getContractAddressAndTransferOwnership.js
	sed -i 's/RRRR/'$ADDRESS'/g' getContractAddressAndTransferOwnership.js
	sed -i 's/TTTT/'$transactionHash'/g' getContractAddressAndTransferOwnership.js
	geth --exec 'loadScript("getContractAddressAndTransferOwnership.js")' attach ipc:eth-data/geth.ipc > contractAddress.txt
	contractAddress=$(head -n 1 contractAddress.txt)
	echo $contractAddress > /var/www/html/contractAddress.html

	# Remove files used with prefilled data
	rm generateContract.js
	rm getContractAddressAndTransferOwnership.js
fi
