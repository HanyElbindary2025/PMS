#!/bin/bash

# DigitalOcean Droplet Setup Script for PMS Project
# Run this script on your new Ubuntu droplet

echo "🚀 Setting up PMS Project on DigitalOcean Droplet..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Node.js 18
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 globally
echo "📦 Installing PM2 process manager..."
npm install -g pm2

# Install PostgreSQL
echo "📦 Installing PostgreSQL..."
apt install postgresql postgresql-contrib -y

# Install Git
echo "📦 Installing Git..."
apt install git -y

# Install Nginx (for reverse proxy)
echo "📦 Installing Nginx..."
apt install nginx -y

# Install Certbot (for SSL)
echo "📦 Installing Certbot for SSL..."
apt install certbot python3-certbot-nginx -y

# Create application user
echo "👤 Creating application user..."
useradd -m -s /bin/bash pms
usermod -aG sudo pms

# Switch to application user
echo "🔄 Switching to application user..."
su - pms << 'EOF'

# Clone repository
echo "📥 Cloning PMS repository..."
git clone https://github.com/HanyElbindary2025/PMS.git
cd PMS

# Install dependencies
echo "📦 Installing Node.js dependencies..."
npm install

# Install Prisma CLI
echo "📦 Installing Prisma CLI..."
npm install -g prisma

# Setup PostgreSQL database
echo "🗄️ Setting up PostgreSQL database..."
sudo -u postgres psql << 'POSTGRES_EOF'
CREATE DATABASE pms_db;
CREATE USER pms_user WITH ENCRYPTED PASSWORD 'secure_password_123';
GRANT ALL PRIVILEGES ON DATABASE pms_db TO pms_user;
\q
POSTGRES_EOF

# Create production .env file
echo "⚙️ Creating production environment file..."
cat > .env << 'ENV_EOF'
NODE_ENV=production
DATABASE_URL="postgresql://pms_user:secure_password_123@localhost:5432/pms_db"
PORT=3000
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"
ENV_EOF

# Run database migrations
echo "🗄️ Running database migrations..."
npx prisma migrate deploy

# Seed database
echo "🌱 Seeding database..."
npx prisma db seed

# Start application with PM2
echo "🚀 Starting application with PM2..."
pm2 start src/index.ts --name pms-backend --interpreter tsx

# Save PM2 configuration
pm2 save

# Setup PM2 startup
pm2 startup

EOF

# Configure Nginx
echo "🌐 Configuring Nginx..."
cat > /etc/nginx/sites-available/pms << 'NGINX_EOF'
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_EOF

# Enable site
ln -s /etc/nginx/sites-available/pms /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx
systemctl restart nginx
systemctl enable nginx

# Configure firewall
echo "🔥 Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Setup automatic updates
echo "🔄 Setting up automatic security updates..."
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Update your domain DNS to point to this server's IP"
echo "2. Run: sudo certbot --nginx -d your-domain.com -d www.your-domain.com"
echo "3. Your PMS will be available at: http://your-domain.com"
echo ""
echo "📊 Useful commands:"
echo "- Check app status: pm2 status"
echo "- View logs: pm2 logs pms-backend"
echo "- Restart app: pm2 restart pms-backend"
echo "- Check Nginx: sudo systemctl status nginx"
echo ""
echo "🔧 Configuration files:"
echo "- App config: /home/pms/PMS/.env"
echo "- Nginx config: /etc/nginx/sites-available/pms"
echo "- PM2 config: ~/.pm2/dump.pm2"
