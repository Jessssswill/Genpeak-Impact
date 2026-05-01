import ShopRepository from "../repository/shop.repository";
import InventoryRepository from "../repository/inventory.repository";
import PurchaseRepository from "../repository/purchase.repository";
import PlayerStatsRepository from "../repository/playerStats.repository";
import { ItemTransactionParams } from "../types/item.types";
import { ServiceResponse } from "../types/response.types";
import { PurchaseResult } from "../types/shop.types";

class ShopService {
    async getAllItems() {
        const weapons = await ShopRepository.findAllWeapons();
        const artifacts = await ShopRepository.findAllArtifacts();

        const weaponItems = weapons.map(weapon => ({
            id: weapon.weaponId,
            name: weapon.name,
            type: weapon.type,
            description: weapon.description,
            element: weapon.element?.type || null,
            stock: weapon.stock,
            imageUrl: weapon.imageUrl,
            price: Number(weapon.price),
            damage: weapon.damage
        }));

        const artifactItems = artifacts.map(artifact => ({
            id: artifact.artifactId,
            name: artifact.name,
            type: artifact.type,
            description: artifact.description,
            element: artifact.element?.type || null,
            stock: artifact.stock,
            imageUrl: artifact.imageUrl,
            price: Number(artifact.price),
            primaryStat: Number(artifact.primaryStat),
            secondaryStat: Number(artifact.secondaryStat)
        }));

        return [...weaponItems, ...artifactItems];
    }

    async purchaseItem({ userId, itemId, itemType }: ItemTransactionParams): Promise<ServiceResponse<PurchaseResult>> {

        let item: any = null;
        let price: number = 0;

        if (itemType === 'Weapon') {
            item = await ShopRepository.findWeaponById(itemId);
        } else if (itemType === 'Artifact') {
            item = await ShopRepository.findArtifactById(itemId);
        }

        if (!item) {
            return {
                data: null,
                message: 'Item not found',
                statusCode: 404
            };
        }

        price = Number(item.price);


        if (item.stock <= 0) {
            return {
                data: null,
                message: 'Item out of stock',
                statusCode: 409
            };
        }


        const playerStats = await PlayerStatsRepository.findByUserId(userId);

        if (!playerStats) {
            return {
                data: null,
                message: 'Player stats not found',
                statusCode: 404
            };
        }

        const playerMoney = Number(playerStats.money);

        if (playerMoney < price) {
            return {
                data: null,
                message: 'Insufficient money',
                statusCode: 400
            };
        }


        const newMoney = playerMoney - price;
        await PlayerStatsRepository.updateMoney(playerStats.playerStatsId, newMoney, userId);


        if (itemType === 'Weapon') {
            await ShopRepository.decrementWeaponStock(itemId);
        } else {
            await ShopRepository.decrementArtifactStock(itemId);
        }


        const purchase = await PurchaseRepository.createPurchase({ userId, itemId, itemType, money: price, createdBy: userId });


        await InventoryRepository.createInventoryItem({ userId, itemId, itemType, createdBy: userId });

        return {
            data: {
                purchaseId: purchase.purchaseId,
                userId: purchase.userId,
                itemId: purchase.itemId,
                itemType: purchase.itemType,
                money: newMoney
            },
            message: 'Item purchased successfully',
            statusCode: 200
        };
    }
}

export default new ShopService();
