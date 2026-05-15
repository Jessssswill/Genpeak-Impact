import { Request, Response } from 'express';

import adminService from '../services/admin.service';
import { handleError } from '../utils/request.util';

class AdminController {
    async getShopItems(req: Request, res: Response): Promise<any> {
        try {
            const items = await adminService.getAllItems();

            res.status(200).json({
                status: 'success',
                message: 'Items fetched successfully',
                data: items,
                error: null
            });

        } catch (error) {
            const err = handleError(error);
            console.log('Error fetching admin shop items: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to fetch shop items',
                data: null,
                error: err.message
            });
        }
    }

    async createItem(req: Request, res: Response): Promise<any> {
        try {
            const createdBy = req.jwtPayload!.id;
            const data = req.body;

            const result = await adminService.createItem(data, createdBy);

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
            console.log('Error creating item: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to create item',
                data: null,
                error: err.message
            });
        }
    }

    async updateItem(req: Request, res: Response): Promise<any> {
        try {
            const id = parseInt(req.params.id as string);
            const updatedBy = req.jwtPayload!.id;
            const data = req.body;

            if (isNaN(id)) {
                return res.status(400).json({
                    status: 'fail',
                    message: 'Invalid item ID',
                    data: null,
                    error: null
                });
            }

            const result = await adminService.updateItem(id, data, updatedBy);

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
            console.log('Error updating item: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to update item',
                data: null,
                error: err.message
            });
        }
    }

<<<<<<< HEAD
=======
    async getEnemies(req: Request, res: Response): Promise<any> {
        try {
            const enemies = await adminService.getAllEnemies();
            res.status(200).json({ status: 'success', message: 'Enemies fetched', data: enemies, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to fetch enemies', data: null, error: err.message });
        }
    }

    async createEnemy(req: Request, res: Response): Promise<any> {
        try {
            const createdBy = req.jwtPayload!.id;
            const result = await adminService.createEnemy(req.body, createdBy);
            if (!result.data) return res.status(result.statusCode).json({ status: 'fail', message: result.message, data: null, error: null });
            res.status(200).json({ status: 'success', message: result.message, data: result.data, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to create enemy', data: null, error: err.message });
        }
    }

    async updateEnemy(req: Request, res: Response): Promise<any> {
        try {
            const id = parseInt(req.params.id as string);
            const updatedBy = req.jwtPayload!.id;
            if (isNaN(id)) return res.status(400).json({ status: 'fail', message: 'Invalid enemy ID', data: null, error: null });
            const result = await adminService.updateEnemy(id, req.body, updatedBy);
            if (!result.data) return res.status(result.statusCode).json({ status: 'fail', message: result.message, data: null, error: null });
            res.status(200).json({ status: 'success', message: result.message, data: result.data, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to update enemy', data: null, error: err.message });
        }
    }

    async deleteEnemy(req: Request, res: Response): Promise<any> {
        try {
            const id = parseInt(req.params.id as string);
            if (isNaN(id)) return res.status(400).json({ status: 'fail', message: 'Invalid enemy ID', data: null, error: null });
            const result = await adminService.deleteEnemy(id);
            if (result.statusCode !== 200) return res.status(result.statusCode).json({ status: 'fail', message: result.message, data: null, error: null });
            res.status(200).json({ status: 'success', message: result.message, data: null, error: null });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Failed to delete enemy', data: null, error: err.message });
        }
    }

>>>>>>> 6b12a73 (update)
    async deleteItem(req: Request, res: Response): Promise<any> {
        try {
            const id = parseInt(req.params.id as string);
            const itemType = req.body.itemType;

            if (isNaN(id)) {
                return res.status(400).json({
                    status: 'fail',
                    message: 'Invalid item ID',
                    data: null,
                    error: null
                });
            }

            const result = await adminService.deleteItem(id, itemType);

            if (result.statusCode !== 200) {
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
                data: null,
                error: null
            });

        } catch (error) {
            const err = handleError(error);
            console.log('Error deleting item: ', err);
            res.status(500).json({
                status: 'error',
                message: 'Failed to delete item',
                data: null,
                error: err.message
            });
        }
    }
}

<<<<<<< HEAD
export default new AdminController();
=======
export default new AdminController();
>>>>>>> 6b12a73 (update)
