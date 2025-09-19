import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create demo users
  const users = [
    {
      email: 'admin@test.com',
      name: 'System Administrator',
      role: 'ADMIN',
      department: 'IT Operations',
      phone: '+1-555-0101',
    },
    {
      email: 'manager@test.com',
      name: 'Service Manager',
      role: 'SERVICE_MANAGER',
      department: 'IT Services',
      phone: '+1-555-0102',
    },
    {
      email: 'servicedesk@test.com',
      name: 'Service Desk Agent',
      role: 'SERVICE_DESK',
      department: 'IT Support',
      phone: '+1-555-0103',
    },
    {
      email: 'analyst@test.com',
      name: 'Technical Analyst',
      role: 'TECHNICAL_ANALYST',
      department: 'IT Architecture',
      phone: '+1-555-0104',
    },
    {
      email: 'developer@test.com',
      name: 'Senior Developer',
      role: 'DEVELOPER',
      department: 'Development',
      phone: '+1-555-0105',
    },
    {
      email: 'qa@test.com',
      name: 'QA Engineer',
      role: 'QA_ENGINEER',
      department: 'Quality Assurance',
      phone: '+1-555-0106',
    },
    {
      email: 'architect@test.com',
      name: 'Solution Architect',
      role: 'SOLUTION_ARCHITECT',
      department: 'IT Architecture',
      phone: '+1-555-0107',
    },
    {
      email: 'devops@test.com',
      name: 'DevOps Engineer',
      role: 'DEVOPS_ENGINEER',
      department: 'Operations',
      phone: '+1-555-0108',
    },
    {
      email: 'creator@test.com',
      name: 'Request Creator',
      role: 'CREATOR',
      department: 'Business',
      phone: '+1-555-0109',
    },
  ];

  for (const userData of users) {
    const existingUser = await prisma.user.findUnique({
      where: { email: userData.email }
    });

    if (!existingUser) {
      await prisma.user.create({
        data: userData
      });
      console.log(`✅ Created user: ${userData.name} (${userData.role})`);
    } else {
      console.log(`⏭️  User already exists: ${userData.name}`);
    }
  }

  // Create some demo lookup data
  const lookups = [
    // Projects
    { type: 'PROJECT', value: 'Customer Portal', order: 1 },
    { type: 'PROJECT', value: 'Mobile App', order: 2 },
    { type: 'PROJECT', value: 'API Gateway', order: 3 },
    { type: 'PROJECT', value: 'Data Analytics', order: 4 },
    
    // Platforms
    { type: 'PLATFORM', value: 'Web', order: 1 },
    { type: 'PLATFORM', value: 'Mobile', order: 2 },
    { type: 'PLATFORM', value: 'Desktop', order: 3 },
    { type: 'PLATFORM', value: 'API', order: 4 },
    
    // Categories
    { type: 'CATEGORY', value: 'Bug Fix', order: 1 },
    { type: 'CATEGORY', value: 'Feature Request', order: 2 },
    { type: 'CATEGORY', value: 'Enhancement', order: 3 },
    { type: 'CATEGORY', value: 'Integration', order: 4 },
    { type: 'CATEGORY', value: 'Performance', order: 5 },
    
    // Priorities
    { type: 'PRIORITY', value: 'Critical', order: 1 },
    { type: 'PRIORITY', value: 'High', order: 2 },
    { type: 'PRIORITY', value: 'Medium', order: 3 },
    { type: 'PRIORITY', value: 'Low', order: 4 },
  ];

  for (const lookupData of lookups) {
    const existingLookup = await prisma.lookup.findUnique({
      where: { 
        type_value: {
          type: lookupData.type,
          value: lookupData.value
        }
      }
    });

    if (!existingLookup) {
      await prisma.lookup.create({
        data: lookupData
      });
      console.log(`✅ Created lookup: ${lookupData.type} - ${lookupData.value}`);
    } else {
      console.log(`⏭️  Lookup already exists: ${lookupData.type} - ${lookupData.value}`);
    }
  }

  console.log('🎉 Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });