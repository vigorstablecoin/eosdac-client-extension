Host a VIGOR DAC member client

Custodians are encouraged to host an instance of the DAC member client (UI), so we have many sites at the same time.

Can customize your instance with your custodian branding.

from the eosDAC repo clone these
https://github.com/eosdac/eosdac-client
https://github.com/eosdac/eosdac-api
https://github.com/eosdac/eosio-statereceiver

then from vigorstablecoin repo clone these:
https://github.com/vigorstablecoin/eosdac-api-extension
https://github.com/vigorstablecoin/eosdac-client-extension

the filler scrapes the blockchain for transactions related to list of designated contracts, it fills a mongo db locally with help of a processor (and amqp for distributed processing), and provides an API for the UI client to access state history. The UI uses quasar/vue and a ton of nodejs to populate the UI with relevant state from the API and pushes user transactions to the blockchain (scatter api is used, which is compatible with any wallet that uses that protocol)

DAC Client Install Notes 20190713

#linux ubuntu 18.04
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
sudo apt remove cmdtest
cd ~
curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install -y nodejs
nodejs -v

#clone github.com/eosdac
git clone --recursive https://github.com/eosdac/eosdac-client.git --branch c7ad5454b89a320715087c120e93f748a0deb65c --single-branch
git clone --recursive https://github.com/eosdac/eosdac-api.git --branch 40ad34b34b42e10b93b4ec3b0221d3e4eee9a310 --single-branch
git clone --recursive https://github.com/eosdac/eosio-statereceiver.git --branch 303afb4233fb696a2bd08c16bde305a391d161da --single-branch

#rabbitmq/erlang install
wget -O - "https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey" | sudo apt-key add -
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.deb.sh | sudo bash
curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
sudo apt-get install apt-transport-https
sudo vi /etc/apt/sources.list.d/bintray.rabbitmq.list (then insert the following deb line)
deb https://dl.bintray.com/rabbitmq-erlang/debian bionic erlang
sudo apt-get install update
sudo apt-get install erlang
sudo apt-get install erlang-nox
sudo apt-get install rabbitmq-server=3.7.14-1

#mongodb install, it's needed by the processor (not the filler)
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 68818C72E52529D4
sudo echo "deb http://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
server_names_hash_bucket_size 64;
sudo systemctl enable mongod
sudo netstat -plntu


apt-get install mongodb-server
sudo service mongodb start
show dbs
use dacmain
db.dropDatabase()
#then check it by typing mongo and you should get a shell, ctrl+d to exit
#use dacmain
#show collections
#db.multisigs.find()
#db.multisigs.find({},field:true,field:true)
#db.multisigs.find({proposal_name:"dlwqnweidimc"})

#db.multisigs.find({action.account:"dacmultisig1",action.name:"proposed"})
#https://stackoverflow.com/questions/16619598/sync-mongodb-via-ssh

#eosio-statereceiver
cd ~/eosio-statereceiver
sudo npm install

#eosdac-api
cd ~/eosdac-api
sudo npm install
git clone https://github.com/vigorstablecoin/eosdac-api-extension.git --branch 52769eff9196df3ebdd94f2a77b0960c6097e0c4 --single-branch
cp ~/eosdac-api/eosdac-api-extension/miannet.config.js ~/eosdac-api/.

#eosdac-filler
cd ~/eosdac-api
sudo npm i -g pm2
# the first time, replay the filler starting at the block number the dac went live using -s
#when started in replay mode (-r) it will create the block range jobs and then individual processes will run each one
#if the filler stops, you can restart it with -p which will continue from where it left off
# (-s block number, -p last block)
CONFIG=mainnet ./eosdac-filler.js -r -s 56700000
# once the filler is caught up to latest block, run pm2 to kick off filler/processor
cd ~/eosdac-api
pm2 start
pm2 delete all
pm2 status
pm2 show

# watchers
# can refresh all the msigs:
# you can let it run until it has got all the msigs, then stop it
CONFIG=mainnet node watchers/replay.js

#for jungle: eosio.msig in eosdac-filler/jungle.config.js should be eosiomsigold It’s the old version of eosio.msig which is deployed on jungle

#you might want to enable the management plugin, to clear the queue, multithreading
sudo rabbitmq-plugins enable rabbitmq-management
sudo rabbitmq-plugins enable rabbitmq-shovel
sudo rabbitmq-plugins enable rabbitmq-shovel-management
sudo lsof -i -P -n | grep LISTEN
sudo rabbitmqctl list_permissions
sudo rabbitmqctl set_user_tags ubuntu administrator
sudo rabbitmqctl set_permissions -p /ubuntu ".*" ".*" ".*"
http://api-dac.vigor.ai:15672/ # see the proccess list in the queue, can purge them if desired
# the filler will populate the queue in rabbitmq, then filler will run each process in the queue and write to mongodb
$ cat /etc/rabbitmq/enabled_plugins
[rabbitmq_management,rabbitmq_shovel,rabbitmq_shovel_management].
https://www.rabbitmq.com/passwords.html


#eosdac-client-extension
cd ~/eosdac-client/src
git clone --recursive https://github.com/vigorstablecoin/eosdac-client-extension.git extensions --branch extension_updated --single-branch

sudo apt-get install nginx
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt install certbot
sudo apt install python-certbot-nginx

#serve up https://api-dac.vigor.ai
sudo mkdir -p /var/www/api-dac.vigor.ai/dist/spa-mat
#put a file in there, index.html
sudo chmod -R 755 /var/www/api-dac.vigor.ai
#create a config file: 
/etc/nginx/sites-available/api-dac.vigor.ai
#uncomment a line in /etc/nginx/nginx.conf
server_names_hash_bucket_size 64;
sudo ln -s /etc/nginx/sites-available/api-dac.vigor.ai /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo certbot --nginx -d api-dac.vigor.ai
CONFIG=mainnet ./eosdac-filler.js -r -s 56700000

#serve up https://vigor.aiCONFIG=mainnet ./eosdac-filler.js -r -s 56700000
sudo mkdir -p /var/www/vigor.ai/dist/spa-mat
sudo chmod -R 755 /var/www/.vigor.ai
#create a config file: 
/etc/nginx/sites-available/vigor.ai
#uncomment a line in /etc/nginx/nginx.conf
sudo ln -s /etc/nginx/sites-available/vigor.ai /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default

#build the client
cd ~/eosdac-client
yarn
DEFAULT_NETWORK=mainnet yarn build
sudo cp -r ~/eosdac-client/dist /var/www/vigor.ai/.
sudo certbot --nginx -d vigor.ai -d www.vigor.ai

sudo nginx -t
sudo systemctl restart nginx

#sudo systemctl stop nginx
#sudo systemctl start nginx
#sudo systemctl reload nginx
#sudo systemctl disable nginx
#sudo systemctl enable nginx

#cd ~/eosdac-client/src/extensions/static/config
#config.mainnet.json
#eosdac endpoint
#https://eu.eosdac.io

#for state history
#ws://ex2.eosdac.io:8080
#ws://as1.eosdac.io:8080

# dns A records for vigor.ai: point all these to the staic IP of the server: @ www and api-dac

#ports to open on the server
SSH	TCP	22	
HTTP	TCP	80	
HTTPS	TCP	443	
Custom	TCP	8382 (~/eosdac-api/ecosystem.config.js)
Custom	TCP	15672 (rabbitmq management plugin)

docs url?
https://api-jungle.eosdac.io/v1/eosdac/docs/index.html


#small patch for buttons on mainpage, add these lines:
src/plugins/config-loader.js
case "external":
        return this.configFile.external;

put these pdf files into dist/spa-mat/
wget https://vig.ai/vigorstablecoin.pdf
wget https://vig.ai/vigor.pdf

change this to false to enable claim all
https://github.com/eosdac/eosdac-client/blob/dev/src/pages/custodian/my-payments.vue#L93

refresh tweak
change the 250 to 750 directly in your client source
https://github.com/eosdac/eosdac-client/blob/dev/src/store/user/actions.js#L237 

change default number of candidates on main page to 48
https://github.com/eosdac/eosdac-client/blob/master/src/pages/vote-custodians.vue#L289

launch dac contract and unlock.
vi ecosystem.config.js and comment out eosdac-filler-mainnet (will uncomment later)
CONFIG=mainnet ./eosdac-filler.js -r -s 56700000
pm2 start (runs the processor and api)
http://api-dac.vigor.ai:15672/ # watch and see the filler populate the queue, can purge if you need, the propcessor works on each process and writes to mongod
#mongo
#use dacmain
#show collection
# after the filler/processor syncs to LIB last irrev block, then 
# uncomment eosdac-filler-mainnet in ecosystem.config.js
# kill the filler
# pm2 delete all
# pm2 start
# pm2 show

#ws://as1.eosdac.io:8080

which state history endpoint are you using?
our as1 server recently died and i have restored it from 1.8 snapshots which means it is not compatible with the eosio-statereceiver
there is a 1.8 tag on eosio-statereceiver, we have another <1.8 state history on ex2
i think it is best that you update though, we dont have long before we all have to be on 1.8
f
stuffed shirt | vig.aiadmin
ws://as1.eosdac.io:8080

Michael Yeates
yeah, thats why
go to the filler/eosio-statehistory folder
git pull, then checkout the 1.8 tag

stuffed shirt | vig.aiadmin
right ok

Michael Yeates
then run npm there and also in the filler folder
then stop both pm2 processes (filler and processor)
you should be able to restart the filler and it will pick up where it left off
check the logs are happy and sending to the queue, then start the processor and check logs

stuffed shirt | vig.aiadmin
ok

# eosio.msig approval table...suddenly it has started using approvals2 table, which has a differnt abi
# here is the fix for that:
https://github.com/vigorstablecoin/eosdac-api-extension

use these two customized files:
eosdac-api/watchers/multisig_proposals.js
eosdac-api/handlers/delta-handler.js

then from the eosdac-api directory:
pm2 delete all
pm2 start
CONFIG=mainnet node ./watchers/replay.js

