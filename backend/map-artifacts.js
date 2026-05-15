import genshin from 'genshin-db';
import fs from 'fs';
import path from 'path';

const ARTIFACTS_DIR = path.resolve(process.cwd(), 'public/images/artifacts');

const PIECE_ORDER = ['Flower of Life', 'Plume of Death', 'Sands of Eon', 'Goblet of Eonothem', 'Circlet of Logos'];

const folders = fs.readdirSync(ARTIFACTS_DIR).filter(f => fs.statSync(path.join(ARTIFACTS_DIR, f)).isDirectory());

const result = [];
const failed = [];

for (const folder of folders) {
  let setName = folder;
  if (setName === 'Maiden') setName = 'Maiden Beloved';
  if (setName === 'Flower of Paradiese lost') setName = 'Flower of Paradise Lost';
  if (setName === 'Hearth of Depth') setName = 'Heart of Depth';
  if (setName === 'Thunder Soother') setName = 'Thundersoother';
  if (setName === 'Vermellion Hereafter') setName = 'Vermillion Hereafter';
  
  const genshinSet = genshin.artifacts(setName, { matchCategories: true, verboseCategories: true });
  let setRef = genshinSet;

  if (!setRef) {
    const search = genshin.artifacts(setName, { matchCategories: true });
    if (search) setRef = search;
  }

  if (!setRef || !setRef.flower) {
    console.error(`Could not find genshin-db set for ${folder} (tried ${setName})`);
    failed.push(folder);
    continue;
  }
  
  const files = fs.readdirSync(path.join(ARTIFACTS_DIR, folder)).filter(f => f.endsWith('.webp'));
  const mappedPieces = new Array(5).fill(null);
  
  for (let i = 0; i < 5; i++) {
    const pieceType = PIECE_ORDER[i];
    const ptKey = pieceType === 'Flower of Life' ? 'flower' : pieceType === 'Plume of Death' ? 'plume' : pieceType === 'Sands of Eon' ? 'sands' : pieceType === 'Goblet of Eonothem' ? 'goblet' : 'circlet';
    
    const pieceObj = setRef[ptKey];
    if (!pieceObj) {
      console.log(`Missing piece obj for ${folder} ${pieceType}`);
      continue;
    }

    const pieceName = pieceObj.name;
    const pieceDesc = pieceObj.description.replace(/"/g, '\\"').replace(/\n/g, ' ');

    const clean = str => str.replace(/['’\-\s_]/g, '').toLowerCase();
    const cleanPieceName = clean(pieceName);
    
    let bestMatch = null;
    for (const file of files) {
      const cleanFileName = clean(file.replace('Item_', '').replace('.webp', ''));
      if (cleanFileName === cleanPieceName || cleanFileName.includes(cleanPieceName) || cleanPieceName.includes(cleanFileName)) {
        bestMatch = file;
        break;
      }
    }
    
    mappedPieces[i] = {
      file: bestMatch,
      name: pieceName.replace(/"/g, '\\"'),
      description: pieceDesc
    };
  }
  
  result.push({
    folder,
    pieces: mappedPieces
  });
}

fs.writeFileSync('mapped_details.json', JSON.stringify(result, null, 2));
console.log('Failed:', failed);
