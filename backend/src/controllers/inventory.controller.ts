import { Request, Response } from 'express';

import inventoryService from '../services/inventory.service';
import { handleError } from '../utils/request.util';

class InventoryController {
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
}

export default new InventoryController();
