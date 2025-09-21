# DigitalOcean Deployment Guide for PMS Project

## 🚀 **Why DigitalOcean?**
- **Reliable**: 99.99% uptime SLA
- **Affordable**: Starting at $5/month
- **Full Control**: Complete server access
- **Easy Scaling**: Upgrade as needed
- **Great Support**: 24/7 assistance

## 💰 **Cost Estimate**
- **Droplet (Server)**: $5-10/month
- **Database**: $15/month (managed PostgreSQL)
- **Total**: ~$20-25/month

## 🛠️ **Deployment Options**

### **Option 1: App Platform (Recommended)**
- **Easiest**: Just connect GitHub and deploy
- **Automatic**: Builds and deploys automatically
- **Cost**: $5-12/month
- **Perfect for**: Quick deployment

### **Option 2: Droplet (VPS)**
- **Full Control**: Complete server access
- **Customizable**: Install anything you need
- **Cost**: $5-10/month
- **Perfect for**: Learning and customization

## 📋 **Prerequisites**
1. **DigitalOcean Account**: Sign up at digitalocean.com
2. **GitHub Repository**: Your code must be on GitHub
3. **Credit Card**: For billing (they accept PayPal too)

## 🚀 **Quick Start (App Platform)**

### **Step 1: Connect GitHub**
1. Go to DigitalOcean App Platform
2. Click "Create App"
3. Connect your GitHub account
4. Select your PMS repository

### **Step 2: Configure Build**
```yaml
# App Spec (auto-generated)
name: pms-backend
services:
- name: api
  source_dir: /
  github:
    repo: HanyElbindary2025/PMS
    branch: master
  run_command: npm start
  environment_slug: node-js
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: NODE_ENV
    value: production
  - key: DATABASE_URL
    value: ${db.DATABASE_URL}
  - key: PORT
    value: "3000"
databases:
- name: db
  engine: PG
  version: "13"
  size: db-s-1vcpu-1gb
```

### **Step 3: Deploy**
1. Review configuration
2. Click "Create Resources"
3. Wait for deployment (5-10 minutes)

## 🖥️ **Alternative: Droplet Setup**

### **Step 1: Create Droplet**
1. Choose Ubuntu 20.04 LTS
2. Select $5/month plan (1GB RAM)
3. Add SSH key
4. Create droplet

### **Step 2: Server Setup**
```bash
# Connect to server
ssh root@your-droplet-ip

# Update system
apt update && apt upgrade -y

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 (process manager)
npm install -g pm2

# Install PostgreSQL
apt install postgresql postgresql-contrib -y
```

### **Step 3: Deploy Application**
```bash
# Clone repository
git clone https://github.com/HanyElbindary2025/PMS.git
cd PMS

# Install dependencies
npm install

# Setup database
npx prisma migrate deploy
npx prisma db seed

# Start application
pm2 start src/index.ts --name pms-backend
pm2 startup
pm2 save
```

## 🔧 **Environment Variables**

### **Production .env**
```env
NODE_ENV=production
DATABASE_URL="postgresql://username:password@localhost:5432/pms_db"
PORT=3000
JWT_SECRET=your-super-secret-jwt-key
```

## 🌐 **Domain Setup**
1. **Buy Domain**: From Namecheap, GoDaddy, etc.
2. **Point DNS**: A record to your droplet IP
3. **SSL Certificate**: Let's Encrypt (free)

## 📊 **Monitoring & Maintenance**
- **Uptime**: DigitalOcean monitoring
- **Logs**: PM2 logs
- **Backups**: Automated database backups
- **Updates**: Regular security updates

## 💡 **Pro Tips**
1. **Start Small**: Begin with $5 plan, upgrade later
2. **Use App Platform**: Easier than managing droplets
3. **Enable Backups**: $1/month for peace of mind
4. **Monitor Usage**: Track resource consumption
5. **Set Alerts**: Get notified of issues

## 🆘 **Support**
- **DigitalOcean Docs**: Comprehensive guides
- **Community**: Active forums
- **24/7 Support**: Paid plans include support
- **Status Page**: Check service status

## 🎯 **Next Steps**
1. **Choose Option**: App Platform or Droplet
2. **Create Account**: Sign up for DigitalOcean
3. **Deploy**: Follow the guide above
4. **Test**: Verify everything works
5. **Share**: Give team access to URLs

---
**Ready to deploy?** Let me know which option you prefer!
