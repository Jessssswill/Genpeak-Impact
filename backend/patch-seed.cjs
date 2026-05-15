const fs = require('fs');

const mapped = JSON.parse(fs.readFileSync('mapped_details.json', 'utf8'));

// Read seed.ts
const seedPath = 'prisma/seed.ts';
let seedContent = fs.readFileSync(seedPath, 'utf8');

// Update type definition
seedContent = seedContent.replace(
  /type ArtifactSetSeed = \{[\s\S]+?\};\n\n\/\/ All 42 sets.+Order: \[Flower.+\]/,
  `type ArtifactSetSeed = {
  folder: string;
  name: string;
  element: string;
  basePrice: number;
  description: string;
  pieces?: ({ file: string; name: string; description: string } | null)[];
};

// All 42 sets are fully hardcoded with explicit pieces. Order: [Flower, Feather, Sands, Goblet, Circlet]`
);


// Find the ARTIFACT_SETS array
const startStr = 'const ARTIFACT_SETS: ArtifactSetSeed[] = [';
const startIdx = seedContent.indexOf(startStr);
const mainIdx = seedContent.indexOf('async function main()');
const endIdx = seedContent.lastIndexOf('];', mainIdx);

if (startIdx === -1 || endIdx === -1) {
    console.error("Could not find ARTIFACT_SETS bounds");
    process.exit(1);
}

let newArrayStr = 'const ARTIFACT_SETS: ArtifactSetSeed[] = [\n';

for (const m of mapped) {
    const escapedFolder = m.folder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const oldRegex = new RegExp(`folder:\\s*"${escapedFolder}"[^}]+}`);
    const oldMatch = seedContent.match(oldRegex);
    let setName = m.folder;
    let element = "Geo";
    let basePrice = 8000;
    let setDescription = m.folder;
    
    if (oldMatch) {
        const str = oldMatch[0];
        const nMatch = str.match(/name:\s*"([^"]+)"/);
        if (nMatch) setName = nMatch[1];
        
        const eMatch = str.match(/element:\s*"([^"]+)"/);
        if (eMatch) element = eMatch[1];
        
        const pMatch = str.match(/basePrice:\s*(\d+)/);
        if (pMatch) basePrice = pMatch[1];
        
        const dMatch = str.match(/description:\s*"([^"]+)"/);
        if (dMatch) setDescription = dMatch[1];
    }
    
    newArrayStr += `  {
    folder: "${m.folder}",
    name: "${setName}",
    element: "${element}",
    basePrice: ${basePrice},
    description: "${setDescription}",
    pieces: [\n`;

    for (let i = 0; i < 5; i++) {
        const piece = m.pieces[i];
        if (piece && piece.file) {
            newArrayStr += `      { file: "${piece.file}", name: "${piece.name}", description: "${piece.description}" },\n`;
        } else {
            newArrayStr += `      null,\n`;
        }
    }
    newArrayStr += `    ]\n  },\n`;
}

let newSeedContent = seedContent.substring(0, startIdx) + newArrayStr + seedContent.substring(endIdx);

// Modify the seed loop
const oldLoopStart = '    let selectedByType: Record<PieceType, string>;';
const oldLoopEnd = '      artifactCount++;\n    }';

const loopStartIdx = newSeedContent.indexOf(oldLoopStart);
const loopEndIdx = newSeedContent.indexOf(oldLoopEnd) + oldLoopEnd.length;

if (loopStartIdx === -1 || loopEndIdx === -1) {
    console.error("Could not find loop bounds");
    process.exit(1);
}

const newLoop = `    for (let i = 0; i < PIECE_TYPES.length; i++) {
      const pieceType = PIECE_TYPES[i];
      const pieceData = cfg?.pieces?.[i];
      if (!pieceData || !pieceData.file) continue;

      const stats = PIECE_STATS[pieceType];
      const imageUrl = \`\${BASE_URL}/artifacts/\${encodeURI(folder)}/\${encodeURI(pieceData.file)}\`;

      await prisma.msArtifact.create({
        data: {
          elementId: elMap[element],
          name: pieceData.name,
          type: pieceType,
          description: pieceData.description,
          stock,
          imageUrl,
          price: basePrice + stats.priceAdd,
          primaryStat: stats.primary,
          secondaryStat: stats.secondary,
          createdAt: now,
          updatedAt: now,
          createdBy: "SEED",
        },
      });
      artifactCount++;
    }`;

newSeedContent = newSeedContent.substring(0, loopStartIdx) + newLoop + newSeedContent.substring(loopEndIdx);

fs.writeFileSync(seedPath, newSeedContent);
console.log("seed.ts patched successfully!");
