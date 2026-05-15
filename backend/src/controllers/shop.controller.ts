import { Request, Response } from 'express';

import shopService from '../services/shop.service';
import { handleError } from '../utils/request.util';

class ShopController {
    async getShopItems(req: Request, res: Response): Promise<any> {
        try {
            const items = await shopService.getAllItems();

            res.status(200).json({
                status: 'success',
                message: 'Items fetched successfully',
                data: items,
                error: null
            });

        } catch (error) {
            const err = handleError(error);
            console.log('Error fetching shop items: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to fetch shop items',
                data: null,
                error: err.message
            });
        }
    }

    async purchaseItem(req: Request, res: Response): Promise<any> {
        try {
            const userId = req.jwtPayload!.id;
            const itemId = parseInt(req.params.id as string);
            const itemType = req.body.itemType;

            if (!itemType || isNaN(itemId)) {
                return res.status(400).json({
                    status: 'fail',
                    message: 'Invalid item data',
                    data: null,
                    error: null
                });
            }

            const result = await shopService.purchaseItem({ userId, itemId, itemType });

            if (!result.data) {
                return res.status(result.statusCode).json({
                    status: 'fail',
                    message: result.message,
                    data: null,
                    error: null
                });
            }

            res.status(200).json({
                status: 'success',
                message: result.message,
                data: result.data,
                error: null
            });

        } catch (error) {
            const err = handleError(error);
            console.log('Error purchasing item: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to purchase item',
                data: null,
                error: err.message
            });
        }
    }
}

<<<<<<< HEAD
export default new ShopController();
=======
export default new ShopController();
>>>>>>> 6b12a73 (update)
