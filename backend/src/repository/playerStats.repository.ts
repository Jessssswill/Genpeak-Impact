import { prisma } from "../config/db";

class PlayerStatsRepository {
    async findByUserId(userId: string) {
        const playerStats = await prisma.trPlayerStats.findFirst({
            where: { userId: userId }
        });

        return playerStats;
    }

    async updateMoney(playerStatsId: number, newMoney: number, updatedBy: string) {
        const updated = await prisma.trPlayerStats.update({
            where: { playerStatsId: playerStatsId },
            data: {
                money: newMoney,
                updatedAt: new Date(),
                updatedBy: updatedBy
            }
        });

        return updated;
    }
<<<<<<< HEAD
}

export default new PlayerStatsRepository();
=======

    async createPlayerStats(userId: string, createdBy: string) {
        const stats = await prisma.trPlayerStats.create({
            data: {
                userId: userId,
                hp: 20000,
                damage: 1500,
                criticalChance: 5.0,
                criticalDamage: 50.0,
                money: 500000,
                createdAt: new Date(),
                createdBy: createdBy,
                updatedAt: new Date(),
                updatedBy: createdBy
            }
        });
        return stats;
    }
}

export default new PlayerStatsRepository();
>>>>>>> 6b12a73 (update)
