import { prisma } from "../config/db";
import { ItemCreationParams } from "../types/item.types";

class InventoryRepository {
    async findByUserId(userId: string) {
        const inventory = await prisma.trInventory.findMany({
            where: { userId: userId }
        });

        return inventory;
    }

    async createInventoryItem(params: ItemCreationParams) {
        const inventoryItem = await prisma.trInventory.create({
            data: {
                userId: params.userId,
                itemId: params.itemId,
                itemType: params.itemType,
                createdAt: new Date(),
                createdBy: params.createdBy,
                updatedAt: new Date(),
                updatedBy: params.createdBy
            }
        });

        return inventoryItem;
    }
}

export default new InventoryRepository();
