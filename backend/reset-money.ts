import { prisma } from './src/config/db.js';

async function main() {
    const userId = '774d90cb-22d8-4e9b-b571-7e7267068f18';

    const items = await prisma.trInventory.findMany({ where: { userId } });
    console.log('Inventory items:');
    for (const item of items) {
        console.log(`  [${item.inventoryId}] ${item.itemType} itemId=${item.itemId} level=${item.level} mainStatValue=${item.mainStatValue}`);
    }

    const before = await prisma.trPlayerStats.findFirst({ where: { userId } });
    console.log(`\nMoney before: ${before?.money}`);

    await prisma.trPlayerStats.updateMany({
        where: { userId },
        data: { money: 500000, updatedAt: new Date(), updatedBy: 'RESET' }
    });

    const after = await prisma.trPlayerStats.findFirst({ where: { userId } });
    console.log(`Money after:  ${after?.money}`);
}

main().finally(() => prisma.$disconnect());
