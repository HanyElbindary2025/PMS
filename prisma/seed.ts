import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create lookup data
  const lookups = [
    // Projects
    { type: 'PROJECT', value: 'Website Redesign', order: 1 },
    { type: 'PROJECT', value: 'Mobile App Development', order: 2 },
    { type: 'PROJECT', value: 'API Integration', order: 3 },
    { type: 'PROJECT', value: 'Database Migration', order: 4 },
    
    // Platforms
    { type: 'PLATFORM', value: 'Web', order: 1 },
    { type: 'PLATFORM', value: 'Mobile', order: 2 },
    { type: 'PLATFORM', value: 'Desktop', order: 3 },
    { type: 'PLATFORM', value: 'API', order: 4 },
    
    // Categories
    { type: 'CATEGORY', value: 'INCIDENT', order: 1 },
    { type: 'CATEGORY', value: 'REQUEST', order: 2 },
    { type: 'CATEGORY', value: 'CHANGE', order: 3 },
    { type: 'CATEGORY', value: 'PROBLEM', order: 4 },
    
    // Priorities
    { type: 'PRIORITY', value: 'CRITICAL', order: 1 },
    { type: 'PRIORITY', value: 'HIGH', order: 2 },
    { type: 'PRIORITY', value: 'MEDIUM', order: 3 },
    { type: 'PRIORITY', value: 'LOW', order: 4 },
  ];

  for (const lookup of lookups) {
    await prisma.lookup.upsert({
      where: { type_value: { type: lookup.type, value: lookup.value } },
      update: {},
      create: lookup,
    });
  }

  // Create default users
  const users = [
    {
      email: 'admin@pms.com',
      name: 'System Administrator',
      role: 'ADMIN',
      department: 'IT',
      phone: '+1-555-0100',
    },
    {
      email: 'service.manager@pms.com',
      name: 'Service Manager',
      role: 'SERVICE_MANAGER',
      department: 'IT',
      phone: '+1-555-0101',
    },
    {
      email: 'service.desk@pms.com',
      name: 'Service Desk Agent',
      role: 'SERVICE_DESK',
      department: 'IT',
      phone: '+1-555-0102',
    },
    {
      email: 'technical.analyst@pms.com',
      name: 'Technical Analyst',
      role: 'TECHNICAL_ANALYST',
      department: 'IT',
      phone: '+1-555-0103',
    },
    {
      email: 'developer@pms.com',
      name: 'Senior Developer',
      role: 'DEVELOPER',
      department: 'Development',
      phone: '+1-555-0104',
    },
    {
      email: 'qa@pms.com',
      name: 'QA Engineer',
      role: 'QA_ENGINEER',
      department: 'Quality Assurance',
      phone: '+1-555-0105',
    },
    {
      email: 'solution.architect@pms.com',
      name: 'Solution Architect',
      role: 'SOLUTION_ARCHITECT',
      department: 'Architecture',
      phone: '+1-555-0106',
    },
    {
      email: 'devops@pms.com',
      name: 'DevOps Engineer',
      role: 'DEVOPS_ENGINEER',
      department: 'Operations',
      phone: '+1-555-0107',
    },
    {
      email: 'operations@pms.com',
      name: 'Operations Engineer',
      role: 'OPERATIONS_ENGINEER',
      department: 'Operations',
      phone: '+1-555-0108',
    },
    {
      email: 'manager@pms.com',
      name: 'IT Manager',
      role: 'MANAGER',
      department: 'Management',
      phone: '+1-555-0109',
    },
    {
      email: 'hany@pms.com',
      name: 'Hany Elbindary',
      role: 'ADMIN',
      department: 'IT',
      phone: '+1-555-0110',
    },
  ];

  for (const user of users) {
    await prisma.user.upsert({
      where: { email: user.email },
      update: {},
      create: user,
    });
  }

  console.log('✅ Database seeded successfully!');
  console.log('👥 Created users:');
  users.forEach(user => {
    console.log(`   • ${user.email} (${user.role})`);
  });
  console.log('📋 Created lookups:');
  console.log(`   • ${lookups.length} lookup entries`);
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });