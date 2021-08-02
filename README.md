# scaling-giggle-api

scaling-giggle-api is a RESTful API for vocabulary trainers. At the time its still experimental and only test questions are available.

## Requirements

- Node.js
- NPM

## Installation

First clone the repository and install the npm packages :

`git clone https://github.com/naseif/vultrDiscordBot.git` <br/>
`cd vultrDiscordBot` <br/>
`npm i`

to start the API simply run the following commands :

`npm start`

the API will be available at https://localhost:51337

## Usage

This is a list of the available endpoints at the moment:

- /training
- /training/:id
- /training/:id/question/:questionID (index of the question in the array)

## Hosting the API and installing SSL Certificate

Me and @stho32 made it as easy as possible. Now you do not have to go through the complex installation yourself anymore.

Assuming you are on a fresh root linux server (e.g vultr.com)

All you have to do after cloning the repository is executing the shell script located inside the hosting directory.

```shell
cd hosting
./setup-hosting.sh
```

This will install **nginx**, **duckdns** (for a free domain) and **LetsEncrypt** to install SSL Certificate for your domain and some important packages such as nodejs, npm and pwsh. It will also copy a system service called `scaling-giggle-env.service` to /etc/systemd/system and enable it after the nginx and LetsEncrypt installation is over. This service will start the API and make sure to restart it if a reboot occurs or if something went wrong

Before you go through the installation make sure to create an account on [duckdns.org](http://www.duckdns.org/) to get your free domain and token.
You will be asked to provide both of them and you will be asked to provide an email for LetsEncrypt. After that, all you have to do is to sit back and let the script do its magic!

Once the script is finished installing and configuring your server, visit your own domain and you should see the API up and running :)

## Contributions

Software contributions are welcome. If you are not a dev, testing and reproting bugs can also be very helpful!

## Questions?

Please open an issue if you have questions, wish to request a feature, etc.
