// Project Organization Script
import fs from 'fs';
import path from 'path';

const projectStructure = {
  'docs': [
    'test-report.html',
    'README.md'
  ],
  'scripts': [
    'simple-test.js',
    'organize-project.js',
    'test-workflow.js'
  ],
  'batch': [
    'start-backend.bat',
    'start-frontend.bat', 
    'start-both.bat',
    'stop-all.bat',
    'auto-commit.bat',
    'auto-commit-progress.bat',
    'commit-all.bat'
  ]
};

function organizeProject() {
  console.log('🗂️  Organizing Project Structure...\n');

  // Create directories
  Object.keys(projectStructure).forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`✅ Created directory: ${dir}/`);
    }
  });

  // Move files to appropriate directories
  Object.entries(projectStructure).forEach(([dir, files]) => {
    files.forEach(file => {
      if (fs.existsSync(file)) {
        const newPath = path.join(dir, file);
        fs.renameSync(file, newPath);
        console.log(`📁 Moved ${file} → ${newPath}`);
      }
    });
  });

  // Create additional organization
  const additionalDirs = [
    'logs',
    'temp',
    'backup'
  ];

  additionalDirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
      console.log(`✅ Created directory: ${dir}/`);
    }
  });

  // Create .gitignore if it doesn't exist
  if (!fs.existsSync('.gitignore')) {
    const gitignoreContent = `# Dependencies
node_modules/
.pnpm-debug.log*

# Production builds
dist/
build/

# Environment variables
.env
.env.local
.env.production

# Database
*.db
*.db-journal

# Logs
logs/
*.log

# Temporary files
temp/
tmp/
*.tmp

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
flutter_*.png
linked_*.ds
unlinked.ds
unlinked_spec.ds

# Coverage
coverage/

# Test results
test-results/
`;
    
    fs.writeFileSync('.gitignore', gitignoreContent);
    console.log('✅ Created .gitignore');
  }

  // Create project summary
  const summary = {
    name: 'Professional PMS System',
    version: '1.0.0',
    status: 'Production Ready',
    lastUpdated: new Date().toISOString(),
    structure: {
      backend: 'Node.js + Express + TypeScript + Prisma',
      frontend: 'Flutter + Dart',
      database: 'SQLite',
      workflow: '15-phase professional ITSM',
      features: [
        'Complete workflow management',
        'Team assignment system',
        'User role management',
        'File upload support',
        'Exception handling',
        'Professional UI'
      ]
    }
  };

  fs.writeFileSync('project-summary.json', JSON.stringify(summary, null, 2));
  console.log('✅ Created project-summary.json');

  console.log('\n🎉 Project organization complete!');
  console.log('\n📁 New structure:');
  console.log('├── docs/           # Documentation and reports');
  console.log('├── scripts/        # Test and utility scripts');
  console.log('├── batch/          # Windows batch files');
  console.log('├── logs/           # Log files');
  console.log('├── temp/           # Temporary files');
  console.log('├── backup/         # Backup files');
  console.log('├── src/            # Backend source code');
  console.log('├── pms_app/        # Flutter frontend');
  console.log('├── prisma/         # Database schema and migrations');
  console.log('└── learn docs/     # Learning documentation');
}

organizeProject().catch(console.error);
