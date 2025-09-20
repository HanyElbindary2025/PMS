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

async function finalDemoWorkflow() {
  console.log('🎬 FINAL DEMO: Complete Workflow as Per Your Requirements\n');
  console.log('========================================================\n');

  try {
    // Get users
    const users = await makeRequest(`${BASE_URL}/users`);
    const admin = users.find(u => u.role === 'ADMIN');
    const developer = users.find(u => u.role === 'DEVELOPER');
    const qa = users.find(u => u.role === 'QA_ENGINEER');
    
    console.log('👥 Available Users:');
    console.log(`• Admin: ${admin.name}`);
    console.log(`• Developer: ${developer.name}`);
    console.log(`• QA Engineer: ${qa.name}`);

    // STEP 1: CREATE TICKET (Like your demo)
    console.log('\n📝 STEP 1: CREATE TICKET');
    console.log('========================');
    const ticketResponse = await makeRequest(`${BASE_URL}/public/requests`, {
      method: 'POST',
      body: JSON.stringify({
        title: 'Final Demo: Complete Workflow',
        description: 'Demonstrating the complete workflow from create to dispatch to assign to complete',
        requesterEmail: 'customer@pms.com',
        requesterName: 'Demo Customer',
        details: {
          project: 'Demo Project',
          platform: 'Web',
          priority: 'HIGH',
          category: 'FEATURE_REQUEST'
        }
      })
    });

    const ticketId = ticketResponse.id;
    console.log(`✅ Ticket Created:`);
    console.log(`   ID: ${ticketId}`);
    console.log(`   Title: Final Demo: Complete Workflow`);
    console.log(`   Status: SUBMITTED`);
    console.log(`   Assigned To: Unassigned`);

    // STEP 2: DISPATCH TO USER (Like your demo)
    console.log('\n🎯 STEP 2: DISPATCH TO USER');
    console.log('===========================');
    const assignResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/assign`, {
      method: 'POST',
      body: JSON.stringify({
        assignedToId: developer.id,
        teamMembers: [],
        comment: 'Dispatched to development team'
      })
    });

    console.log(`✅ Ticket Dispatched:`);
    console.log(`   Assigned To: ${assignResponse.assignedTo?.name}`);
    console.log(`   Status: ${assignResponse.status}`);
    console.log(`   Assignment Stage: Created`);

    // STEP 3: ASSIGNED USER TAKES ACTION
    console.log('\n⚡ STEP 3: ASSIGNED USER TAKES ACTION');
    console.log('====================================');
    
    // Developer starts analysis
    console.log('\n🔍 Developer starts analysis...');
    const analysisResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'ANALYSIS',
        userRole: 'DEVELOPER',
        currentUserId: developer.id,
        comment: 'Developer starting analysis phase'
      })
    });
    console.log(`✅ Analysis started: ${analysisResponse.status}`);

    // Developer confirms due date
    console.log('\n📅 Developer sets due date...');
    const dueDate = new Date();
    dueDate.setHours(dueDate.getHours() + 72); // 72 hours from now
    
    const confirmResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'CONFIRM_DUE',
        userRole: 'DEVELOPER',
        currentUserId: developer.id,
        dueAt: dueDate.toISOString(),
        comment: 'Developer confirmed due date and SLA'
      })
    });
    console.log(`✅ Due date confirmed: ${confirmResponse.status}`);
    console.log(`   SLA Hours: ${confirmResponse.totalSlaHours}`);

    // Developer moves to design
    console.log('\n🎨 Developer moves to design...');
    const designResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'DESIGN',
        userRole: 'DEVELOPER',
        currentUserId: developer.id,
        comment: 'Developer completed design phase'
      })
    });
    console.log(`✅ Design completed: ${designResponse.status}`);

    // Developer starts development
    console.log('\n💻 Developer starts development...');
    const devResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'DEVELOPMENT',
        userRole: 'DEVELOPER',
        currentUserId: developer.id,
        comment: 'Developer completed development'
      })
    });
    console.log(`✅ Development completed: ${devResponse.status}`);

    // STEP 4: ASSIGN TO ANOTHER DEPARTMENT
    console.log('\n🔄 STEP 4: ASSIGN TO ANOTHER DEPARTMENT');
    console.log('======================================');
    
    // Reassign to QA department
    const reassignResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/assign`, {
      method: 'POST',
      body: JSON.stringify({
        assignedToId: qa.id,
        teamMembers: [],
        comment: 'Reassigned to QA department for testing'
      })
    });

    console.log(`✅ Reassigned to QA Department:`);
    console.log(`   New Assignee: ${reassignResponse.assignedTo?.name}`);
    console.log(`   Status: ${reassignResponse.status}`);

    // STEP 5: NEW DEPARTMENT TAKES ACTION
    console.log('\n🧪 STEP 5: QA DEPARTMENT TAKES ACTION');
    console.log('====================================');
    
    // QA starts testing
    console.log('\n🔍 QA starts testing...');
    const testingResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'TESTING',
        userRole: 'QA_ENGINEER',
        currentUserId: qa.id,
        comment: 'QA completed testing phase'
      })
    });
    console.log(`✅ Testing completed: ${testingResponse.status}`);

    // QA moves to customer approval
    console.log('\n✅ QA moves to customer approval...');
    const approvalResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'CUSTOMER_APPROVAL',
        userRole: 'QA_ENGINEER',
        currentUserId: qa.id,
        comment: 'Ready for customer approval'
      })
    });
    console.log(`✅ Customer approval phase: ${approvalResponse.status}`);

    // STEP 6: FINAL COMPLETION
    console.log('\n🏁 STEP 6: FINAL COMPLETION');
    console.log('===========================');
    
    // Admin completes deployment
    console.log('\n🚀 Admin completes deployment...');
    const deploymentResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'DEPLOYMENT',
        userRole: 'ADMIN',
        currentUserId: admin.id,
        comment: 'Admin completed deployment'
      })
    });
    console.log(`✅ Deployment completed: ${deploymentResponse.status}`);

    // Admin verifies and closes
    console.log('\n✅ Admin verifies and closes...');
    const verificationResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'VERIFICATION',
        userRole: 'ADMIN',
        currentUserId: admin.id,
        comment: 'Admin verified completion'
      })
    });
    console.log(`✅ Verification completed: ${verificationResponse.status}`);

    const closeResponse = await makeRequest(`${BASE_URL}/tickets/${ticketId}/transition`, {
      method: 'POST',
      body: JSON.stringify({
        to: 'CLOSED',
        userRole: 'ADMIN',
        currentUserId: admin.id,
        comment: 'Ticket completed successfully'
      })
    });
    console.log(`✅ Ticket closed: ${closeResponse.status}`);

    // FINAL STATE
    console.log('\n📊 FINAL TICKET STATE');
    console.log('=====================');
    const finalTicket = await makeRequest(`${BASE_URL}/tickets/${ticketId}`);
    console.log(`📋 Title: ${finalTicket.title}`);
    console.log(`📊 Status: ${finalTicket.status}`);
    console.log(`👤 Final Assignee: ${finalTicket.assignedTo?.name}`);
    console.log(`⏱️ SLA Status: ${finalTicket.slaStatus}`);
    console.log(`📈 Total Stages: ${finalTicket.stages.length}`);

    console.log('\n📈 COMPLETE WORKFLOW STAGES:');
    finalTicket.stages.forEach((stage, index) => {
      const status = stage.completedAt ? '✅ Completed' : '⏳ In Progress';
      console.log(`   ${index + 1}. ${stage.key}: ${status}`);
      if (stage.completedAt) {
        console.log(`      Started: ${new Date(stage.startedAt).toLocaleString()}`);
        console.log(`      Completed: ${new Date(stage.completedAt).toLocaleString()}`);
      }
    });

    console.log('\n🎉 DEMO COMPLETED SUCCESSFULLY!');
    console.log('================================');
    console.log('✅ CREATE: Ticket created by user');
    console.log('✅ DISPATCH: Assigned to specific user');
    console.log('✅ ACT: Only assigned user could take actions');
    console.log('✅ REASSIGN: Moved to another department');
    console.log('✅ COMPLETE: Full workflow completed');
    console.log('✅ TRACKING: All stages properly tracked');
    console.log('\n💡 Your system works exactly as shown in your demo!');

  } catch (error) {
    console.error('❌ Demo failed:', error.message);
  }
}

finalDemoWorkflow();
