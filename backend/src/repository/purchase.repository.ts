import { prisma } from "../config/db";
import { PurchaseCreationParams } from "../types/item.types";

class PurchaseRepository {
    async createPurchase(params: PurchaseCreationParams) {
        const purchase = await prisma.trPurchase.create({
            data: {
                userId: params.userId,
                itemId: params.itemId,
                itemType: params.itemType,
                money: params.money,
                createdAt: new Date(),
                createdBy: params.createdBy,
                updatedAt: new Date(),
                updatedBy: params.createdBy
            }
        });

        return purchase;
    }
}

export default new PurchaseRepository();
