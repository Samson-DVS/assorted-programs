#!/bin/bash
#about: this script make sure the linux system is secured with basic security practices and the webserver (APACHE) configured with the recommended industry security standards. This script can be combined with Amazon Cloudformation to form as a template. Other options includes of using with Zapier, and so on
# Note: the programs such as GIT, NPM, etc versions installed are more recent as of the date this script is made. Kindly ensure these programs updated. The scriot focuses on running a MERN stack application

          # Log file path
          LOG_FILE="/var/log/setup.log"

          # Function to log messages to file
          log_file() {
              local timestamp=$(date +"%d:%b:%Y, %H:%M:%S")
              echo "[$timestamp] $1" >> "$LOG_FILE"
          }

          # Function to log messages using Syslog
          log_syslog() {
              local timestamp=$(date +"%d:%b:%Y, %H:%M:%S")
              echo "$timestamp $1" | sudo tee -a /dev/null | sudo logger -p local0.notice
          }

          # Redirect stdout and stderr to log file
          exec > >(tee -a "$LOG_FILE")
          exec 2>&1

          # Create log file and set permissions
          touch "$LOG_FILE"
          chmod 644 "$LOG_FILE"

          ##########################
          # User Accounts
          ##########################

          log_file "Creating user accounts..."

          # Create user accounts
          sudo useradd -m -s /bin/bash hello
          echo "hello:V@i!slkwiofd" | sudo chpasswd

          log_file "User accounts created."

          # Change root password
          echo "Root:@kwi12345psk!" | sudo chpasswd

          ##########################
          # SSH Configuration
          ##########################

          log_file "Configuring SSH..."

          # Disable root login via SSH
          sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
          sudo service ssh restart

          # Change SSH port and configure UFW rules
          sudo sed -i 's/#Port 22/Port 30/' /etc/ssh/sshd_config
          sudo ufw allow 30
          sudo ufw reload

          log_file "SSH configuration completed."

          ##########################
          # System Security
          ##########################

          log_file "Configuring system security..."
          
          
          # Enable MOTD banner
          sudo apt-get install -y figlet
          sudo tee -a /etc/motd > /dev/null << EOF
          *********************************************************************
          *               WARNING: THIS SYSTEM IS UNDER MONITORING             *
         *********************************************************************
          EOF
          
          #Removal of legacy Services
          sudo apt-get purge apache2 mysql-server perl php tomcat8

          # Install and configure Fail2Ban
          sudo apt-get install -y fail2ban
          sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
          sudo tee -a /etc/fail2ban/jail.local > /dev/null << EOF
          [sshd]
          enabled = true
          port = 30
          maxretry = 3
          bantime = 5600
          EOF
          sudo systemctl restart fail2ban

          # Enable automatic security updates
          sudo apt-get install -y unattended-upgrades
          sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << EOF
          APT::Periodic::Update-Package-Lists "1";
          APT::Periodic::Unattended-Upgrade "1";
          EOF

         log_file "System security configuration completed."

          ##########################
          # Web Server Configuration
          ##########################

          log_file "Configuring web server..."
                    
          # Install and configure Apache web server
          sudo apt-get install -y apache2

         
          # Configure Apache security settings
          sudo sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
          sudo sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf
          echo "Options -Indexes" | sudo tee /etc/apache2/conf-available/disable-directory-listing.conf > /dev/null
          sudo a2enconf disable-directory-listing
          sudo a2dissite 000-default.conf

          # Restart Apache service
          sudo systemctl restart apache2

          # Configure HTTP response headers for security
          sudo tee /etc/apache2/conf-available/security-headers.conf > /dev/null << EOF
          Header always set X-Frame-Options SAMEORIGIN
          Header always set X-XSS-Protection "1; mode=block"
          Header always set Content-Security-Policy "default-src 'self'"
          Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
          EOF
          sudo a2enconf security-headers

          # Hide Apache version information
          echo "ServerTokens Prod" | sudo tee -a /etc/apache2/conf-available/security.conf > /dev/null
          echo "ServerSignature Off" | sudo tee -a /etc/apache2/conf-available/security.conf > /dev/null
          echo "FileETag None" | sudo tee -a /etc/apache2/conf-available/security.conf > /dev/null

          # Disable .htaccess override
          sudo tee -a /etc/apache2/apache2.conf > /dev/null << EOF
          <Directory /var/www/>
              AllowOverride None
          </Directory>
          EOF

          # Disable SSI and CGI
          sudo a2dismod include
          sudo a2dismod cgi

          # Restart Apache service
          sudo systemctl restart apache2

          log_file "Web server configuration completed."

          ##########################
          # Firewall Configuration
          ##########################

          log_file "Configuring firewall..."

          # Configure UFW limits
          sudo tee -a /etc/sysctl.conf > /dev/null << EOF
          net.core.somaxconn = 1024
          fs.file-max = 65536
          EOF
          sudo sysctl -p

          # Enable UFW firewall
          sudo apt-get install -y ufw
          sudo ufw default deny incoming
          sudo ufw default allow outgoing
          sudo ufw allow 30
          sudo ufw allow http
          sudo ufw allow https
          sudo ufw enable

          log_file "Firewall configuration completed."

          ##########################
          # Application Deployment
          ##########################          

          # Install Git
          sudo apt-get install -y git

          # Install Node.js and npm
          curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
          sudo apt-get install -y nodejs

          # Install PM2
          sudo npm install -g pm2

          # Install Yarn
          curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
          echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
          sudo apt-get update
          sudo apt-get install -y yarn

          # Install NVM (Node Version Manager)
          curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
