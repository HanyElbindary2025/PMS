import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function checkUsers() {
  try {
    const users = await prisma.user.findMany();
    console.log('Current users in database:');
    console.log('========================');
    users.forEach(user => {
      console.log(`Email: ${user.email}`);
      console.log(`Name: ${user.name}`);
      console.log(`Role: ${user.role}`);
      console.log(`Active: ${user.isActive}`);
      console.log('---');
    });
    
    // Check specifically for admin user
    const adminUser = await prisma.user.findUnique({
      where: { email: 'admin@pms.com' }
    });
    
    if (adminUser) {
      console.log('\nAdmin user found:');
      console.log(`Email: ${adminUser.email}`);
      console.log(`Role: ${adminUser.role}`);
      console.log(`Active: ${adminUser.isActive}`);
    } else {
      console.log('\n❌ Admin user NOT found!');
    }
    
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkUsers();
