import InventoryRepository from "../repository/inventory.repository";
import ShopRepository from "../repository/shop.repository";
import PlayerStatsRepository from "../repository/playerStats.repository";
import { upgradeSubstats } from "../utils/rng.util";

import { InventoryItem } from "../types/shop.types";

class InventoryService {
    async getInventory(userId: string): Promise<{
        data: InventoryItem[] | null,
        message: string
    }> {
        const inventoryItems = await InventoryRepository.findByUserId(userId);

        const enrichedItems: InventoryItem[] = [];

        for (const item of inventoryItems) {
            let fullItem: any = {};

            if (item.itemType === 'Weapon') {
                const weapon = await ShopRepository.findWeaponById(item.itemId);
                if (weapon) {
                    fullItem = {
                        id: weapon.weaponId,
                        name: weapon.name,
                        type: weapon.type,
                        description: weapon.description,
                        elementId: weapon.elementId,
                        stock: weapon.stock,
                        imageUrl: weapon.imageUrl,
                        price: Number(weapon.price),
                        damage: weapon.damage
                    };
                }
            } else if (item.itemType === 'Artifact') {
                const artifact = await ShopRepository.findArtifactById(item.itemId);
                if (artifact) {
                    fullItem = {
                        id: artifact.artifactId,
                        name: artifact.name,
                        setName: artifact.setName,
                        type: artifact.type,
                        description: artifact.description,
                        elementId: artifact.elementId,
                        stock: artifact.stock,
                        imageUrl: artifact.imageUrl,
                        price: Number(artifact.price),
                        primaryStat: Number(artifact.primaryStat),
                        secondaryStat: Number(artifact.secondaryStat)
                    };
                }
            }

            // Parse substats
            let parsedSubstats: { stat: string; value: number }[] = [];
            if (item.substats != null) {
                const raw = item.substats;
                if (typeof raw === 'string') {
                    try { parsedSubstats = JSON.parse(raw); } catch { parsedSubstats = []; }
                } else if (Array.isArray(raw)) {
                    parsedSubstats = raw as { stat: string; value: number }[];
                }
            }
            const maxSubstats = Math.min(4, Math.floor(item.level / 4) + 1);

            enrichedItems.push({
                ...fullItem,
                inventoryId: item.inventoryId,
                itemCategory: item.itemType,
                level: item.level,
                reinforceLevel: item.reinforceLevel ?? 0,
                mainStatValue: (item.mainStatValue != null && Number(item.mainStatValue) > 0)
                    ? Number(item.mainStatValue)
                    : Number(fullItem.primaryStat ?? fullItem.damage ?? 0),
                substats: parsedSubstats.slice(0, maxSubstats)
            });
        }

        return {
            data: enrichedItems,
            message: 'Inventory fetched successfully'
        };
    }

    // ─── Artifact upgrade: +1 level, max 20, cost 3 000 Mora ─────────────────
    async upgradeArtifact(userId: string, inventoryId: number): Promise<any> {
        const item = await InventoryRepository.findInventoryItemById(inventoryId);
        if (!item || item.userId !== userId) {
            return { data: null, message: 'Item not found in inventory', statusCode: 404 };
        }
        if (item.itemType !== 'Artifact') {
            return { data: null, message: 'Only artifacts can be upgraded', statusCode: 400 };
        }
        if (item.level >= 20) {
            return { data: null, message: 'Artifact is already at max level', statusCode: 400 };
        }

        const playerStats = await PlayerStatsRepository.findByUserId(userId);
        if (!playerStats) {
            return { data: null, message: 'Player stats not found', statusCode: 404 };
        }

        const upgradeCost = 3000;
        const currentMoney = playerStats.money.toNumber();
        if (currentMoney < upgradeCost) {
            return { data: null, message: `Insufficient Mora for upgrade (need ${upgradeCost}, have ${Math.floor(currentMoney)})`, statusCode: 400 };
        }

        const newMoney = currentMoney - upgradeCost;
        await PlayerStatsRepository.updateMoney(playerStats.playerStatsId, newMoney, userId);

        const newLevel = item.level + 1;

        // Substats: unlock every 4 levels (0→1, 4→2, 8→3, 12→4)
        let rawSubstats = item.substats;
        if (typeof rawSubstats === 'string') {
            try { rawSubstats = JSON.parse(rawSubstats); } catch { rawSubstats = []; }
        }
        let newSubstats: { stat: string; value: number }[] = Array.isArray(rawSubstats) ? rawSubstats as any : [];
        const expectedCount = Math.min(4, Math.floor(item.level / 4) + 1);
        newSubstats = newSubstats.slice(0, expectedCount);
        newSubstats = upgradeSubstats(newSubstats);

        // Main stat: recalculate from base each time to avoid compounding drift
        const artifactData = await ShopRepository.findArtifactById(item.itemId);
        const basePrimary = Number(artifactData?.primaryStat ?? 0);
        const newMain = basePrimary * (1 + newLevel * 0.05);

        const updatedItem = await InventoryRepository.updateInventoryItem(inventoryId, {
            level: newLevel,
            mainStatValue: newMain,
            substats: newSubstats,
            updatedBy: userId
        });

        return {
            data: {
                id: artifactData?.artifactId,
                name: artifactData?.name ?? '',
                setName: artifactData?.setName ?? '',
                type: artifactData?.type ?? '',
                description: artifactData?.description ?? '',
                elementId: artifactData?.elementId,
                stock: artifactData?.stock,
                imageUrl: artifactData?.imageUrl ?? '',
                price: Number(artifactData?.price ?? 0),
                primaryStat: Number(artifactData?.primaryStat ?? 0),
                secondaryStat: Number(artifactData?.secondaryStat ?? 0),
                inventoryId: updatedItem.inventoryId,
                itemCategory: 'Artifact',
                level: updatedItem.level,
                reinforceLevel: updatedItem.reinforceLevel ?? 0,
                mainStatValue: Number(updatedItem.mainStatValue ?? 0),
                substats: updatedItem.substats,
                money: newMoney
            },
            message: `Artifact upgraded to +${newLevel}!`,
            statusCode: 200
        };
    }

    // ─── Weapon upgrade: +1 level, max 90, cost scales per tier ─────────────
    async upgradeWeapon(userId: string, inventoryId: number): Promise<any> {
        const item = await InventoryRepository.findInventoryItemById(inventoryId);
        if (!item || item.userId !== userId) {
            return { data: null, message: 'Item not found in inventory', statusCode: 404 };
        }
        if (item.itemType !== 'Weapon') {
            return { data: null, message: 'Only weapons can be upgraded here', statusCode: 400 };
        }
        if (item.level >= 90) {
            return { data: null, message: 'Weapon is already at max level', statusCode: 400 };
        }

        const playerStats = await PlayerStatsRepository.findByUserId(userId);
        if (!playerStats) {
            return { data: null, message: 'Player stats not found', statusCode: 404 };
        }

        // Cost: 1 000 for L0–29, 2 000 for L30–59, 3 000 for L60–89
        const upgradeCost = (Math.floor(item.level / 30) + 1) * 1000;
        const currentMoney = playerStats.money.toNumber();
        if (currentMoney < upgradeCost) {
            return { data: null, message: `Insufficient Mora for upgrade (need ${upgradeCost}, have ${Math.floor(currentMoney)})`, statusCode: 400 };
        }

        const newMoney = currentMoney - upgradeCost;
        await PlayerStatsRepository.updateMoney(playerStats.playerStatsId, newMoney, userId);

        const newLevel = item.level + 1;
        const weaponData = await ShopRepository.findWeaponById(item.itemId);
        const baseDamage = weaponData?.damage ?? 0;
        // Scaled ATK: base × (1 + level × 0.6 / 90) → at L90 = base × 1.6
        const newMain = Math.round(baseDamage * (1 + newLevel * 0.6 / 90));

        const updatedItem = await InventoryRepository.updateInventoryItem(inventoryId, {
            level: newLevel,
            mainStatValue: newMain,
            updatedBy: userId
        });

        return {
            data: {
                id: weaponData?.weaponId,
                name: weaponData?.name ?? '',
                type: weaponData?.type ?? '',
                description: weaponData?.description ?? '',
                elementId: weaponData?.elementId,
                stock: weaponData?.stock,
                imageUrl: weaponData?.imageUrl ?? '',
                price: Number(weaponData?.price ?? 0),
                damage: weaponData?.damage ?? 0,
                inventoryId: updatedItem.inventoryId,
                itemCategory: 'Weapon',
                level: newLevel,
                reinforceLevel: 0,
                mainStatValue: newMain,
                substats: updatedItem.substats,
                money: newMoney
            },
            message: `Weapon upgraded to Lv.${newLevel}!`,
            statusCode: 200
        };
    }

    // ─── Reinforce: consume 2 same artifacts → +1 tier, +25% mainStat ────────
    async reinforceArtifact(userId: string, inventoryId: number, consumeIds: number[]): Promise<any> {
        if (!Array.isArray(consumeIds) || consumeIds.length !== 2) {
            return { data: null, message: 'Provide exactly 2 item IDs to consume', statusCode: 400 };
        }

        const target = await InventoryRepository.findInventoryItemById(inventoryId);
        if (!target || target.userId !== userId) {
            return { data: null, message: 'Item not found in inventory', statusCode: 404 };
        }
        if (target.itemType !== 'Artifact') {
            return { data: null, message: 'Only artifacts can be reinforced', statusCode: 400 };
        }

        for (const cid of consumeIds) {
            const consumed = await InventoryRepository.findInventoryItemById(cid);
            if (!consumed || consumed.userId !== userId) {
                return { data: null, message: `Consumed item ${cid} not found`, statusCode: 404 };
            }
            if (consumed.itemId !== target.itemId || consumed.itemType !== 'Artifact') {
                return { data: null, message: 'Consumed items must be the same artifact type', statusCode: 400 };
            }
        }

        for (const cid of consumeIds) {
            await InventoryRepository.deleteInventoryItem(cid);
        }

        const artifactData = await ShopRepository.findArtifactById(target.itemId);
        const currentMain = (target.mainStatValue != null && Number(target.mainStatValue) > 0)
            ? Number(target.mainStatValue)
            : Number(artifactData?.primaryStat ?? 0);
        const newMain = currentMain * 1.25;
        const newReinforceLevel = (target.reinforceLevel ?? 0) + 1;

        const updatedItem = await InventoryRepository.updateInventoryItem(inventoryId, {
            mainStatValue: newMain,
            reinforceLevel: newReinforceLevel,
            updatedBy: userId
        });

        return {
            data: {
                id: artifactData?.artifactId,
                name: artifactData?.name ?? '',
                setName: artifactData?.setName ?? '',
                type: artifactData?.type ?? '',
                description: artifactData?.description ?? '',
                elementId: artifactData?.elementId,
                stock: artifactData?.stock,
                imageUrl: artifactData?.imageUrl ?? '',
                price: Number(artifactData?.price ?? 0),
                primaryStat: Number(artifactData?.primaryStat ?? 0),
                secondaryStat: Number(artifactData?.secondaryStat ?? 0),
                inventoryId: updatedItem.inventoryId,
                itemCategory: 'Artifact',
                level: updatedItem.level,
                reinforceLevel: newReinforceLevel,
                mainStatValue: Number(updatedItem.mainStatValue ?? 0),
                substats: updatedItem.substats,
            },
            message: `Artifact reinforced to tier ${newReinforceLevel}!`,
            statusCode: 200
        };
    }
}

export default new InventoryService();
