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

In order to host the API you will need a fresh root linux server (e.g vultr.com)

After you have cloned the repository into your server, you have to install **nginx**, **duckdns** (for a free domain) and **LetsEncrypt**

Installing all these packages and configuring them can be tricky so you can use [swizzin](https://swizzin.ltd/) for that. Run the following command which will start the swizzin installation :
`bash <(curl -sL git.io/swizzin) && . ~/.bashrc`

You will be asked to create a home user but you can skip this step. After Swizzin has successfully installed and assuming you are on root, type `box` in the console and select install package and install the following packages in this order :

- Nginx
- duckdns
- LetsEncrypt

Before you start the duckdns installation, go to [duckdns.org](http://www.duckdns.org/) and create your own account and then create a domain name and paste this and your token when swizzin asks for them when you start the installation.

LetsEncrypt will ask you for your domain and then if to configure it as swizzin default config which you should answer with yes. Your domain is not managed by cloudflare so answer this with no. A SSL certificate will be issued for your server and you should try if its working by visiting `mydomain.com`

Once you are finished with these steps we can now route the api to your domain :

- Go to /etc/nginx/sites-enabled
- type `cd nano default`
- replace the content there with the following:

```service
server {
listen 80;
server_name mydomain.com;
return 301 https://$host$request_uri;
}

server {
listen 443 ssl;
server_name mydomain.com;
ssl_certificate /etc/nginx/ssl/mydomain.com/fullchain.pem;
ssl_certificate_key /etc/nginx/ssl/mydomain.com/key.pem;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
        location /  {
                proxy_pass    http://localhost:51337;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }

}

```

then simply restart the nginx service `systemctl restart nginx`

And thats it!

## Contributions

Software contributions are welcome. If you are not a dev, testing and reproting bugs can also be very helpful!

## Questions?

Please open an issue if you have questions, wish to request a feature, etc.
