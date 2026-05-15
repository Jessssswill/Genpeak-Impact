import genshin from 'genshin-db';
import fs from 'fs';
import path from 'path';

const folder = 'Maiden';
const setName = 'Maiden Beloved';
const genshinSet = genshin.artifacts(setName, { matchCategories: true, verboseCategories: true });

console.log("Flower name from DB:", genshinSet.flower.name);

const ARTIFACTS_DIR = path.resolve(process.cwd(), 'public/images/artifacts');
const files = fs.readdirSync(path.join(ARTIFACTS_DIR, folder)).filter(f => f.endsWith('.webp'));
console.log("Files:", files);
