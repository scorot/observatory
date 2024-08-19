# Enable PHP with nginx

This status page requires PHP to be enabled. Since I use nginx, and PHP is not installed and enable by defaults, it is something that must be performed afterward. Hopefully I found a guide on this page : https://www.themoderncoder.com/install-php-on-raspberry-pi-with-nginx/

Here is the installation process based on the reference above.

# PHP setup for NGINX

##  Install NGINX

PHP is compiled by a webserver and the one we’ll be using is NGINX. For more information about installing NGINX, follow my NGINX installation guide for the Raspberry Pi.

## Install PHP

Once you’ve installed NGINX, follow these instructions to allow NGINX to interpret PHP on your Raspberry Pi.
Install PHP-FPM

php-fpm is a fast php interpretor. Install it using the below command.

```
sudo apt install php-fpm
```

Bind NGINX to PHP

Open up the NGINX virtual host config file (found here /etc/nginx/sites-enabled/default), and look for this line

```
index index.html index.htm index.nginx-debian.html;
```

and replace it with this line

```
index index.html index.htm index.php;
```

Next look for the config block in the virtual host config file (again found here /etc/nginx/sites-enabled/default) that starts with this:

```
location ~ \.php$ {
  ...
}
```

and uncomment it so it looks like this

```
location ~ \.php$ {
  include snippets/fastcgi-php.conf;
  fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
}
```

This will bind NGINX to the faster PHP interpretor (php-fpm) we just installed.
Test PHP

To test that PHP is working, put a “index.php” file in the root directory of your webserver (by default “/var/www/html/”) and restart NGINX using the commands below:

```
echo "<?php phpinfo(); ?>" > /var/www/html/index.php

sudo /etc/init.d/nginx restart
```

Now when you go to http://pi1.local/ (replace “pi1.local” with the IP address of your Raspberry Pi) you should see a page displaying information about PHP.
