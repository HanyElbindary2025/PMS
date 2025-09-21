#!/bin/bash

# Render Deployment Script for PMS Project

echo "🚀 Preparing PMS Project for Render Deployment..."

# 1. Copy production package.json
echo "📦 Setting up production package.json..."
cp package-production.json package.json

# 2. Copy production tsconfig.json
echo "⚙️ Setting up production TypeScript config..."
cp tsconfig-production.json tsconfig.json

# 3. Update Prisma schema for production
echo "🗄️ Updating Prisma schema for production..."
sed -i 's/provider = "sqlite"/provider = "postgresql"/' prisma/schema.prisma

# 4. Create .env.production
echo "🔐 Creating production environment file..."
cat > .env.production << EOF
DATABASE_URL="postgresql://username:password@host:port/database"
PORT=10000
NODE_ENV=production
EOF

# 5. Create render.yaml for easy deployment
echo "📋 Creating Render configuration..."
cat > render.yaml << EOF
services:
  - type: web
    name: pms-backend
    env: node
    plan: free
    buildCommand: npm install && npm run build && npm run prisma:generate
    startCommand: npm start
    envVars:
      - key: DATABASE_URL
        sync: false
      - key: PORT
        value: 10000
      - key: NODE_ENV
        value: production

  - type: static
    name: pms-blueprint
    buildCommand: echo "Static site ready"
    staticPublishPath: ./blueprint
    routes:
      - type: rewrite
        source: /*
        destination: /ms-project-table.html
EOF

echo "✅ Deployment files created!"
echo ""
echo "📋 Next Steps:"
echo "1. Push your code to GitHub"
echo "2. Go to https://dashboard.render.com"
echo "3. Click 'New Web Service'"
echo "4. Connect your GitHub repository"
echo "5. Use the generated render.yaml configuration"
echo "6. Add your DATABASE_URL environment variable"
echo "7. Deploy!"
echo ""
echo "🎯 For Static Site (Blueprint only):"
echo "1. Click 'New Static Site'"
echo "2. Set publish directory to 'blueprint'"
echo "3. Deploy!"
