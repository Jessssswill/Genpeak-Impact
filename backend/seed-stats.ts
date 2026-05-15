import { prisma } from './src/config/db.js';

async function main() {
  const users = await prisma.msUser.findMany();
  let created = 0, updated = 0;

  for (const u of users) {
    const existing = await prisma.trPlayerStats.findFirst({ where: { userId: u.userId } });
    if (!existing) {
      await prisma.trPlayerStats.create({
        data: {
          userId: u.userId,
          hp: 10000,
          damage: 1500,
          criticalChance: 5.0,
          criticalDamage: 100.0,
          money: 500000,
          createdAt: new Date(),
          createdBy: 'SEED_STATS',
          updatedAt: new Date(),
          updatedBy: 'SEED_STATS',
        },
      });
      created++;
    } else {
      await prisma.trPlayerStats.update({
        where: { playerStatsId: existing.playerStatsId },
        data: {
          hp: 10000,
          damage: 1500,
          criticalChance: 5.0,
          criticalDamage: 100.0,
          money: 500000,
          updatedAt: new Date(),
          updatedBy: 'SEED_STATS',
        },
      });
      updated++;
    }
  }
  console.log(`Player stats: ${created} created, ${updated} updated.`);
}

main().finally(() => prisma.$disconnect());
