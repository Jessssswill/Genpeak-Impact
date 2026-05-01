import InventoryRepository from "../repository/inventory.repository";
import ShopRepository from "../repository/shop.repository";

import { InventoryItem } from "../types/shop.types";

class InventoryService {
    async getInventory(userId: string): Promise<{
        data: InventoryItem[] | null,
        message: string
    }> {
        const inventoryItems = await InventoryRepository.findByUserId(userId);

        const enrichedItems: InventoryItem[] = [];

        for (const item of inventoryItems) {
            let name = '';
            let imageUrl = '';

            if (item.itemType === 'Weapon') {
                const weapon = await ShopRepository.findWeaponById(item.itemId);
                name = weapon?.name || '';
                imageUrl = weapon?.imageUrl || '';
            } else if (item.itemType === 'Artifact') {
                const artifact = await ShopRepository.findArtifactById(item.itemId);
                name = artifact?.name || '';
                imageUrl = artifact?.imageUrl || '';
            }

            enrichedItems.push({
                inventoryId: item.inventoryId,
                itemId: item.itemId,
                itemType: item.itemType,
                name: name,
                imageUrl: imageUrl
            });
        }

        return {
            data: enrichedItems,
            message: 'Inventory fetched successfully'
        };
    }
}

export default new InventoryService();
