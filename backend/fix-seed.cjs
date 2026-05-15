const fs = require('fs');

const seedPath = 'prisma/seed.ts';
const content = fs.readFileSync(seedPath, 'utf8');

const lines = content.split(/\r?\n/);

let newLines = [];
let foundDupe = false;
for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('}mport { PrismaMariaDb }')) {
        newLines.push('    }'); // close the inner loop
        break;
    }
    newLines.push(lines[i]);
}

// Now append the rest of the main function from the end of the file
let endBlockStart = -1;
for (let i = lines.length - 1; i >= 0; i--) {
    if (lines[i].includes('console.log(`  ✅ ${artifactCount} artifacts created')) {
        endBlockStart = i - 1; // get the closing brace of the outer loop
        break;
    }
}

if (endBlockStart !== -1) {
    for (let i = endBlockStart; i < lines.length; i++) {
        newLines.push(lines[i]);
    }
}

fs.writeFileSync(seedPath, newLines.join('\n'));
console.log('Fixed seed.ts');
