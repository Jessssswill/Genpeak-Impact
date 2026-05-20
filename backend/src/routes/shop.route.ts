import { Router } from "express";
import shopController from "../controllers/shop.controller";

const router = Router();

router.get('/', shopController.getShopItems.bind(shopController));
router.post('/:id', shopController.purchaseItem.bind(shopController));

export default router;
