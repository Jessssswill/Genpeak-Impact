import { Router } from "express";
import inventoryController from "../controllers/inventory.controller";

const router = Router();

router.get('/', inventoryController.getInventory.bind(inventoryController));

export default router;
