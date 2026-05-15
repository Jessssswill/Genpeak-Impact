import { prisma } from './src/config/db.js'; async function main() { const stats = await prisma.trPlayerStats.findMany(); console.log('Stats:', stats); } main().finally(() => prisma.$disconnect());
