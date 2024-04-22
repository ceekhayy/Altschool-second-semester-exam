#!/bin/bash

# Update Linux system
sudo apt update

# Install Apache web server
sudo apt install apache2 -y

# Add the PHP Ondrej repository
sudo add-apt-repository ppa:ondrej/php -y

# Update repository again
sudo apt update

# Install PHP 8.2 and necessary extensions
sudo apt install php8.2 php8.2-curl php8.2-dom php8.2-mbstring php8.2-xml php8.2-mysql zip unzip -y

# Enable Apache rewrite module
sudo a2enmod rewrite

# Restart Apache server
sudo systemctl restart apache2

# Install Composer
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# Change directory to /var/www and clone Laravel repository
cd /var/www/ || exit
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel || exit

# Install Composer dependencies
sudo composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction

# Copy .env.example to .env
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

# Create Apache virtual host configuration
sudo tee /etc/apache2/sites-available/laravel.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/laravel-error.log
    CustomLog \${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF

# Enable Laravel virtual host and disable default virtual host
sudo a2ensite laravel.conf
sudo a2dissite 000-default.conf

# Restart Apache server
A
sudo systemctl restart apache2

# Install MySQL server and client
sudo apt install mysql-server -y

# Start MySQL service and create database and user
sudo systemctl start mysql
sudo mysql -uroot -e "CREATE DATABASE Precious;"
sudo mysql -uroot -e "CREATE USER 'Ckay'@'localhost' IDENTIFIED BY 'Presh67921';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Precious.* TO 'Ckay'@'localhost';"

# Update .env file with MySQL configuration
sudo sed -i "23s/^#//g; 24s/^#//g; 25s/^#//g; 26s/^#//g; 27s/^#//g" /var/www/laravel/.env
sudo sed -i '22s/=sqlite/=mysql/; 23s/=127.0.0.1/=localhost/; 24s/=3306/=3306/; 25s/=laravel/=Precious/; 26s/=root/=Ckay/; 27s/=/=Presh67921/' /var/www/laravel/.env

A
# Generate application key and create symbolic link for storage
sudo php artisan key:generate
sudo php artisan storage:link

A
# Run database migrations and seeding
sudo php artisan migrate
sudo php artisan db:seed

# Restart Apache server
sudo systemctl restart apache2

