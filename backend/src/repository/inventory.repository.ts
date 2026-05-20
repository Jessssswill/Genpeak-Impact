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
                level: params.level ?? 0,
                mainStatValue: params.mainStatValue ?? null,
                substats: params.substats ?? null,
                createdAt: new Date(),
                createdBy: params.createdBy,
                updatedAt: new Date(),
                updatedBy: params.createdBy
            }
        });

        return inventoryItem;
    }

    async findInventoryItemById(inventoryId: number) {
        return await prisma.trInventory.findUnique({
            where: { inventoryId }
        });
    }

    async updateInventoryItem(inventoryId: number, data: any) {
        return await prisma.trInventory.update({
            where: { inventoryId },
            data: {
                ...data,
                updatedAt: new Date()
            }
        });
    }

    async deleteInventoryItem(inventoryId: number) {
        return await prisma.trInventory.delete({ where: { inventoryId } });
    }
}

export default new InventoryRepository();
