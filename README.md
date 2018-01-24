# humans.vote
Blockchain voting for humans

## Design documentation
[Google Doc with stuff](https://docs.google.com/document/d/1HivUUGqH4lilm60n36SA12tUegNr2g3yyi_9uRWT29I/edit#)
# humans.vote
Blockchain voting for humans

## Design documentation
[Google Doc with stuff](https://docs.google.com/document/d/1HivUUGqH4lilm60n36SA12tUegNr2g3yyi_9uRWT29I/edit#)

## Installation instructions - Debian
### User (voter)
#### Miner
The purpose of user becoming a miner is to ensure that transactions are validated by multiple nodes, so the certainty of the system is increased. 

##### Instructions:
* ```apt-get install git```
* ```git clone https://github.com/danesjenovdan/humans.vote.git```
* ```cd humans.vote```
* ```chmod +x setup.sh```
* ```./setup.sh```
* When promted for the IP, enter the IP or domain name of the main party server, where enode information is available.
* When prompted for the wallet address enter your wallet address, that was generated in the mobile application. 
  * This will save any mined resources into your wallet.
  * Private key is not needed for mining into your account, however if you plan to use your node to send resources, voting (sending transactions) or for any other purpose involving use of your wallet you will need to install your private key into eth-data/keystore/.
  * If you do not enter an address one will be automatically generated for you. In this case you will be prompted to enter password for the private key.
 * When prompted if this is main node, enter "n" for no.

### Administrator (party official)
#### Bootstrap node
##### Instructions:

* ```apt-get install git```
* ```git clone https://github.com/danesjenovdan/humans.vote.git```
* ```cd humans.vote```
* ```chmod +x setup.sh```
* ```./setup.sh```
* When promted for the IP, enter the IP or domain name of the main party server, where enode information is available.
* When prompted for the wallet address enter your wallet address, that was generated in the mobile application. 
  * This will save any mined resources into your wallet.
  * Private key is not needed for mining into your account, however if you plan to use your node to send resources, voting (sending transactions) or for any other purpose involving use of your wallet you will need to install your private key into eth-data/keystore/.
  * If you do not enter an address one will be automatically generated for you. In this case you will be prompted to enter password for the private key.
 * When prompted if this is main node, enter "y" for yes.
 * When prompted for the organisation name, please enter your organisation name, as it is stored on the blockchain.
* During the installation the following executes:
	* All dependencies are installed
	* Wallet is generated
	* genesis.json is generated
	* Bootnode is started
	* Miner is started
	* Basic contract is written into the blockchain
	* enode address is exposed
	* contract wallet is exposed

## Setup bootstrap node or miner for debian
```apt install git```
```git clone https://github.com/danesjenovdan/humans.vote.git```

```cd humans.vote```

```sudo sh setup.sh```
