import { prisma } from './src/config/db.js';

async function main() {
  const r1 = await prisma.msArtifact.updateMany({ where: { type: 'Flower'  }, data: { primaryStat: 20000 } });
  const r2 = await prisma.msArtifact.updateMany({ where: { type: 'Feather' }, data: { primaryStat: 3000  } });
  const r3 = await prisma.msArtifact.updateMany({ where: { type: 'Sands'   }, data: { primaryStat: 110   } });
  const r4 = await prisma.msArtifact.updateMany({ where: { type: 'Goblet'  }, data: { primaryStat: 200   } });
  const r5 = await prisma.msArtifact.updateMany({ where: { type: 'Circlet' }, data: { primaryStat: 75    } });
  console.log(`Artifacts updated — Flower:${r1.count} Feather:${r2.count} Sands:${r3.count} Goblet:${r4.count} Circlet:${r5.count}`);

  const w1 = await prisma.msWeapon.updateMany({ where: { damage: 542 }, data: { damage: 1500 } });
  const w2 = await prisma.msWeapon.updateMany({ where: { damage: 608 }, data: { damage: 2000 } });
  const w3 = await prisma.msWeapon.updateMany({ where: { damage: 674 }, data: { damage: 2500 } });
  console.log(`Weapons updated — tier1:${w1.count} tier2:${w2.count} tier3:${w3.count}`);
}

main().finally(() => prisma.$disconnect());
