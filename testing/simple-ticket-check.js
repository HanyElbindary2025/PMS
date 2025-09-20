const BASE_URL = 'http://localhost:3000';

async function checkTickets() {
  console.log('🔍 Checking tickets...');
  
  try {
    const response = await fetch(`${BASE_URL}/tickets?page=1&pageSize=10`);
    
    if (!response.ok) {
      console.log(`❌ HTTP Error: ${response.status}`);
      return;
    }
    
    const data = await response.json();
    console.log(`✅ Found ${data.data.length} tickets:`);
    
    data.data.forEach((ticket, index) => {
      console.log(`${index + 1}. ${ticket.ticketNumber || 'No Number'} - ${ticket.title} (${ticket.status})`);
      console.log(`   Assigned: ${ticket.assignedTo?.name || 'Unassigned'}`);
    });
    
  } catch (error) {
    console.log(`❌ Error: ${error.message}`);
  }
}

checkTickets();
