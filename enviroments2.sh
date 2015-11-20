#!/usr/bin/env bash


#sudo cp ${pathToResources}/Fortinet_CA_SSLProxy.crt /usr/local/share/ca-certificates/
#sudo update-ca-certificates
#sudo chmod +r /usr/local/share/ca-certificates/Fortinet_CA_SSLProxy.crt
#vagrant box add ubuntu/trusty32 --cacert /usr/local/share/ca-certificates/Fortinet_CA_SSLProxy.crt

LOG_PATH="/vagrant/log.txt"
RESOURCES_PATH="/vagrant/resources"

function configureSystem()
{
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "${GREEN}[${time}][System] Konfiguracja systemu.${NORMAL}" 
    {
		# ustawienie czasu lokalnego
        sudo timedatectl set-timezone Europe/Warsaw
        # kopiowanie certyfikatu Fortinet
        sudo cp ${pathToResources}/Fortinet_CA_SSLProxy.crt /usr/local/share/ca-certificates/
        sudo update-ca-certificates
		sudo chmod +r /usr/local/share/ca-certificates/Fortinet_CA_SSLProxy.crt
    } &>> $LOG_PATH
}

function updateSystem
{
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "${GREEN}[${time}][System] Aktualizacja systemu.${NORMAL}" 
    {
        sudo apt-get update
        sudo apt-get -y upgrade
    } &>> $LOG_PATH
}

function installZsh
{
    local pathToResources="${SCRIPTS_PATH}/resources"
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "${GREEN}[${time}][System] Instalacja oraz konfiguracja Zsh.${NORMAL}" 
    {
        sudo apt-get install -y curl git zsh unzip
		wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh 
		sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' ~/.zshrc
		cp -rv ~/.zshrc /home/vagrant/
		cp -rv ~/.oh-my-zsh /home/vagrant/
		sed -i 's,export ZSH=/root/.oh-my-zsh,export ZSH=/home/vagrant/.oh-my-zsh,g' /home/vagrant/.zshrc
		chown vagrant:vagrant -R /home/vagrant/.oh-my-zsh
		chown vagrant:vagrant -R /home/vagrant/.zshrc
		sudo chsh -s /bin/zsh vagrant	
    } &>> $LOG_PATH
}

function installAndConfigurePHP
{
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "${GREEN}[${time}][System] Instalacja oraz konfiguracja PHP 5.5.${NORMAL}" 

    {
        sudo apt-get -y install php5 php5-curl php5-cli php5-gd php5-ldap php5-mysql php5-mysql php5-mcrypt php-apc php5-xdebug php5-xsl php-pear
        sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/apache2/conf.d/20-mcrypt.ini
        sudo ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
        sudo sed -i "s/memory_limit =.*/memory_limit = 2048M/g" /etc/php5/apache2/php.ini
        sudo sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/apache2/php.ini
        sudo sed -i "s/memory_limit =.*/memory_limit = 1024M/g" /etc/php5/cli/php.ini
        sudo service apache2 restart
    } &>> $LOG_PATH
}

function installAndConfigureApache
{
    local time=$(date "+%Y-%m-%d %H:%M:%S")

    echo -e "${GREEN}[${time}][System] Instalacja oraz konfiguracja Apache 2.4.${NORMAL}" 
    {
        sudo apt-get -y install apache2
        sudo service apache2 restart
    } &>> $LOG_PATH
}

# Konfiguracja systemu.
#eval configureSystem

# Aktualizacja systemu.
#eval updateSystem

# Instalacja Zsh.
#eval installZsh

# Instalacja Apache
eval installAndConfigureApache

# Instalacja PHP
eval installAndConfigurePHP
