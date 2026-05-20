import { Router } from "express";
import adminController from "../controllers/admin.controller";

const router = Router();

router.get('/shop', adminController.getShopItems.bind(adminController));
router.post('/shop/item', adminController.createItem.bind(adminController));
router.put('/shop/item/:id', adminController.updateItem.bind(adminController));
router.delete('/shop/item/:id', adminController.deleteItem.bind(adminController));

router.get('/enemies', adminController.getEnemies.bind(adminController));
router.post('/enemies', adminController.createEnemy.bind(adminController));
router.put('/enemies/:id', adminController.updateEnemy.bind(adminController));
router.delete('/enemies/:id', adminController.deleteEnemy.bind(adminController));

export default router;
