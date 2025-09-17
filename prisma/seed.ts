import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding database...');

  // Create lookup values for dropdowns
  const lookups = [
    // Projects
    { type: 'PROJECT', value: 'Orange', order: 1 },
    { type: 'PROJECT', value: 'ET', order: 2 },
    { type: 'PROJECT', value: 'MOD', order: 3 },
    
    // Platforms
    { type: 'PLATFORM', value: 'Autin', order: 1 },
    { type: 'PLATFORM', value: 'Tool', order: 2 },
    
    // Categories
    { type: 'CATEGORY', value: 'Issue', order: 1 },
    { type: 'CATEGORY', value: 'Requirement', order: 2 },
    { type: 'CATEGORY', value: 'Change', order: 3 },
    
    // Priorities
    { type: 'PRIORITY', value: 'High', order: 1 },
    { type: 'PRIORITY', value: 'Medium', order: 2 },
    { type: 'PRIORITY', value: 'Low', order: 3 },
  ];

  for (const lookup of lookups) {
    await prisma.lookup.upsert({
      where: { 
        type_value: { 
          type: lookup.type, 
          value: lookup.value 
        } 
      },
      update: lookup,
      create: lookup,
    });
  }

  console.log('Database seeded successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
