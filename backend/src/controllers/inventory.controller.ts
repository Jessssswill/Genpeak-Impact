import { Request, Response } from 'express';

import inventoryService from '../services/inventory.service';
import PlayerStatsRepository from '../repository/playerStats.repository';
import { handleError } from '../utils/request.util';

class InventoryController {
    async getPlayerStats(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const stats = await PlayerStatsRepository.findByUserId(userId);
            if (!stats) {
                return res.status(404).json({ status: 'fail', message: 'Player stats not found', data: null, error: null });
            }
            res.status(200).json({
                status: 'success',
                message: 'Player stats fetched',
                data: {
                    playerStatsId: stats.playerStatsId,
                    userId: stats.userId,
                    hp: stats.hp,
                    damage: stats.damage,
                    criticalChance: Number(stats.criticalChance),
                    criticalDamage: Number(stats.criticalDamage),
                    money: Number(stats.money),
                },
                error: null
            });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to fetch player stats', data: null, error: err.message });
        }
    }

    async getInventory(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;

            const result = await inventoryService.getInventory(userId);

            res.status(200).json({
                status: 'success',
                message: result.message,
                data: result.data,
                error: null
            });

        } catch (error) {
            const err = handleError(error);
            console.log('Error fetching inventory: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to fetch inventory',
                data: null,
                error: err.message
            });
        }
    }

    async claimBattleReward(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const amount = Number(req.body.amount);

            if (!Number.isFinite(amount) || amount <= 0 || amount > 10_000_000) {
                return res.status(400).json({ status: 'fail', message: 'Invalid reward amount', data: null, error: null });
            }

            const stats = await PlayerStatsRepository.findByUserId(userId);
            if (!stats) {
                return res.status(404).json({ status: 'fail', message: 'Player stats not found', data: null, error: null });
            }

            const newMoney = Number(stats.money) + amount;
            await PlayerStatsRepository.updateMoney(stats.playerStatsId, newMoney, userId);

            res.status(200).json({
                status: 'success',
                message: 'Reward claimed',
                data: { money: newMoney },
                error: null
            });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to claim reward', data: null, error: err.message });
        }
    }

    async upgradeArtifact(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const inventoryId = parseInt(req.params.id as string);
            if (isNaN(inventoryId)) return res.status(400).json({ status: 'fail', message: 'Invalid inventory ID', data: null, error: null });
            const result = await inventoryService.upgradeArtifact(userId, inventoryId);
            res.status(result.statusCode).json({ status: result.statusCode === 200 ? 'success' : 'fail', message: result.message, data: result.data, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to upgrade artifact', data: null, error: err.message });
        }
    }

    async upgradeWeapon(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const inventoryId = parseInt(req.params.id as string);
            if (isNaN(inventoryId)) return res.status(400).json({ status: 'fail', message: 'Invalid inventory ID', data: null, error: null });
            const result = await inventoryService.upgradeWeapon(userId, inventoryId);
            res.status(result.statusCode).json({ status: result.statusCode === 200 ? 'success' : 'fail', message: result.message, data: result.data, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to upgrade weapon', data: null, error: err.message });
        }
    }

    async reinforceArtifact(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const inventoryId = parseInt(req.params.id as string);
            const consumeIds: number[] = req.body.consumeIds ?? [];
            if (isNaN(inventoryId)) return res.status(400).json({ status: 'fail', message: 'Invalid inventory ID', data: null, error: null });
            const result = await inventoryService.reinforceArtifact(userId, inventoryId, consumeIds);
            res.status(result.statusCode).json({ status: result.statusCode === 200 ? 'success' : 'fail', message: result.message, data: result.data, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to reinforce artifact', data: null, error: err.message });
        }
    }
}

export default new InventoryController();
