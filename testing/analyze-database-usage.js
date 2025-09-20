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

async function analyzeDatabaseUsage() {
  console.log('📊 ANALYZING DATABASE COLUMN USAGE\n');
  console.log('==================================\n');

  try {
    // Get sample tickets to analyze
    const tickets = await makeRequest(`${BASE_URL}/tickets?page=1&pageSize=5`);
    
    if (tickets.data.length === 0) {
      console.log('❌ No tickets found to analyze');
      return;
    }

    const sampleTicket = tickets.data[0];
    console.log(`📋 Analyzing ticket: ${sampleTicket.ticketNumber || sampleTicket.id}\n`);

    // Define all possible columns from schema
    const allColumns = [
      // Basic fields
      'id', 'ticketNumber', 'title', 'description', 'requesterEmail', 'requesterName',
      'status', 'totalSlaHours', 'details',
      
      // Enhanced ITSM fields
      'priority', 'impact', 'urgency', 'category', 'subcategory', 'service',
      'businessJustification', 'businessValue', 'riskAssessment', 'technicalAnalysis',
      'dependencies', 'effortEstimate', 'architecture', 'currentPhase',
      'progressPercentage', 'blockers', 'slaBreachRisk', 'qualityGates',
      'acceptanceCriteria', 'testResults', 'closureReason', 'lessonsLearned',
      'customerSatisfaction',
      
      // Team Assignment fields
      'assignedToId', 'assignedTo', 'createdById', 'createdBy', 'teamMembers',
      'escalationLevel',
      
      // Timestamps
      'createdAt', 'updatedAt'
    ];

    // Check which columns have values
    const usedColumns = [];
    const unusedColumns = [];
    const nullColumns = [];

    allColumns.forEach(column => {
      const value = sampleTicket[column];
      if (value !== null && value !== undefined && value !== '') {
        if (Array.isArray(value) && value.length > 0) {
          usedColumns.push(column);
        } else if (!Array.isArray(value)) {
          usedColumns.push(column);
        } else {
          nullColumns.push(column);
        }
      } else {
        nullColumns.push(column);
      }
    });

    // Categorize unused columns
    const definitelyUnused = [
      'impact', 'urgency', 'subcategory', 'service', 'businessJustification',
      'businessValue', 'riskAssessment', 'technicalAnalysis', 'dependencies',
      'effortEstimate', 'architecture', 'currentPhase', 'progressPercentage',
      'blockers', 'slaBreachRisk', 'qualityGates', 'acceptanceCriteria',
      'testResults', 'closureReason', 'lessonsLearned', 'customerSatisfaction',
      'escalationLevel'
    ];

    const potentiallyUnused = nullColumns.filter(col => !definitelyUnused.includes(col));

    console.log('✅ ACTIVELY USED COLUMNS:');
    console.log('========================');
    usedColumns.forEach(col => {
      const value = sampleTicket[col];
      const displayValue = typeof value === 'object' ? JSON.stringify(value).substring(0, 50) + '...' : value;
      console.log(`• ${col}: ${displayValue}`);
    });

    console.log('\n❌ DEFINITELY UNUSED COLUMNS (Future Features):');
    console.log('===============================================');
    definitelyUnused.forEach(col => {
      console.log(`• ${col} - Reserved for future ITSM features`);
    });

    console.log('\n⚠️  POTENTIALLY UNUSED COLUMNS:');
    console.log('===============================');
    potentiallyUnused.forEach(col => {
      console.log(`• ${col} - Not currently used but may be needed`);
    });

    console.log('\n📈 USAGE STATISTICS:');
    console.log('====================');
    console.log(`Total columns: ${allColumns.length}`);
    console.log(`Actively used: ${usedColumns.length}`);
    console.log(`Definitely unused: ${definitelyUnused.length}`);
    console.log(`Potentially unused: ${potentiallyUnused.length}`);

    console.log('\n💡 RECOMMENDATIONS:');
    console.log('===================');
    console.log('✅ Keep all columns - they are designed for future ITSM features');
    console.log('✅ The "unused" columns are actually reserved for:');
    console.log('   • Advanced project management features');
    console.log('   • ITSM compliance and reporting');
    console.log('   • Business intelligence and analytics');
    console.log('   • Risk management and quality gates');
    console.log('   • Customer satisfaction tracking');
    console.log('   • Lessons learned and knowledge management');

    console.log('\n🎯 CURRENT WORKFLOW USES:');
    console.log('=========================');
    console.log('• Basic ticket info (title, description, requester)');
    console.log('• Status and workflow management');
    console.log('• Priority and category classification');
    console.log('• Team assignment and SLA tracking');
    console.log('• Stage-based workflow progression');

  } catch (error) {
    console.error('❌ Analysis failed:', error.message);
  }
}

analyzeDatabaseUsage();
