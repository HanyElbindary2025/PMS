const BASE_URL = 'http://localhost:3000';

async function makeRequest(url, options = {}) {
  const response = await fetch(url, {
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    ...options,
  });
  
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(`HTTP ${response.status}: ${errorData.error || response.statusText}`);
  }
  
  return response.json();
}

async function debugTicketAssignment() {
  console.log('🔍 DEBUGGING TICKET ASSIGNMENT ISSUE\n');
  console.log('====================================\n');

  try {
    // 1. Get all tickets to find the problematic one
    console.log('📋 Getting all tickets...');
    const tickets = await makeRequest(`${BASE_URL}/tickets?page=1&pageSize=50`);
    
    console.log(`Found ${tickets.data.length} tickets:`);
    tickets.data.forEach((ticket, index) => {
      console.log(`${index + 1}. ${ticket.ticketNumber} - ${ticket.title} (${ticket.status})`);
      console.log(`   Assigned To: ${ticket.assignedTo?.name || 'Unassigned'}`);
      console.log(`   Team Members: ${ticket.teamMembers || 'None'}`);
      console.log('');
    });

    // 2. Find tickets in TESTING phase or ready for TESTING
    console.log('🧪 Looking for tickets ready for TESTING...');
    const testingTickets = tickets.data.filter(t => 
      t.status === 'TESTING' || 
      t.status === 'DEVELOPMENT' || 
      t.status === 'DESIGN'
    );
    
    if (testingTickets.length > 0) {
      console.log(`Found ${testingTickets.length} tickets ready for testing:`);
      testingTickets.forEach(ticket => {
        console.log(`• ${ticket.ticketNumber} - ${ticket.title} (${ticket.status})`);
      });
    } else {
      console.log('No tickets found ready for testing phase.');
    }

    // 3. Get users for assignment
    console.log('\n👥 Getting available users...');
    const users = await makeRequest(`${BASE_URL}/users`);
    const qaUsers = users.filter(u => u.role === 'QA_ENGINEER');
    const developers = users.filter(u => u.role === 'DEVELOPER');
    
    console.log(`QA Engineers: ${qaUsers.length}`);
    qaUsers.forEach(qa => console.log(`  • ${qa.name} (${qa.id})`));
    
    console.log(`Developers: ${developers.length}`);
    developers.forEach(dev => console.log(`  • ${dev.name} (${dev.id})`));

    // 4. Test assignment to a ticket
    if (testingTickets.length > 0) {
      const testTicket = testingTickets[0];
      console.log(`\n🎯 Testing assignment on ticket: ${testTicket.ticketNumber}`);
      
      if (qaUsers.length > 0) {
        const qaUser = qaUsers[0];
        console.log(`\n📝 Assigning to QA: ${qaUser.name}`);
        
        try {
          const assignResponse = await makeRequest(`${BASE_URL}/tickets/${testTicket.id}/assign`, {
            method: 'POST',
            body: JSON.stringify({
              assignedToId: qaUser.id,
              teamMembers: [],
              comment: 'Debug assignment test'
            })
          });
          
          console.log(`✅ Assignment successful:`);
          console.log(`   Assigned To: ${assignResponse.assignedTo?.name}`);
          console.log(`   Status: ${assignResponse.status}`);
          
        } catch (error) {
          console.log(`❌ Assignment failed: ${error.message}`);
        }
      }
    }

    // 5. Test transition to TESTING
    if (testingTickets.length > 0) {
      const testTicket = testingTickets[0];
      console.log(`\n🔄 Testing transition to TESTING for: ${testTicket.ticketNumber}`);
      
      if (qaUsers.length > 0) {
        const qaUser = qaUsers[0];
        
        try {
          const transitionResponse = await makeRequest(`${BASE_URL}/tickets/${testTicket.id}/transition`, {
            method: 'POST',
            body: JSON.stringify({
              to: 'TESTING',
              userRole: 'QA_ENGINEER',
              currentUserId: qaUser.id,
              comment: 'Moving to testing phase'
            })
          });
          
          console.log(`✅ Transition successful:`);
          console.log(`   New Status: ${transitionResponse.status}`);
          console.log(`   Assigned To: ${transitionResponse.assignedTo?.name || 'Unassigned'}`);
          
        } catch (error) {
          console.log(`❌ Transition failed: ${error.message}`);
        }
      }
    }

    // 6. Check role permissions
    console.log('\n🔒 Checking role permissions...');
    const rolePermissions = {
      'QA_ENGINEER': ['TESTING', 'CUSTOMER_APPROVAL', 'ON_HOLD'],
      'DEVELOPER': ['ANALYSIS', 'CONFIRM_DUE', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'ON_HOLD'],
      'ADMIN': ['SUBMITTED', 'ANALYSIS', 'CONFIRM_DUE', 'MEETING_REQUESTED', 'DESIGN', 'DEVELOPMENT', 'TESTING', 'CUSTOMER_APPROVAL', 'DEPLOYMENT', 'VERIFICATION', 'CLOSED', 'ON_HOLD', 'REJECTED', 'CANCELLED']
    };
    
    console.log('Role permissions:');
    Object.entries(rolePermissions).forEach(([role, permissions]) => {
      console.log(`  ${role}: ${permissions.join(', ')}`);
    });

  } catch (error) {
    console.error('❌ Debug failed:', error.message);
  }
}

debugTicketAssignment();
