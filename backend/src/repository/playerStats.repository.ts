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
}

export default new PlayerStatsRepository();
