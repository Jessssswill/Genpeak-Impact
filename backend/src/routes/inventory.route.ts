import { Router } from "express";
import inventoryController from "../controllers/inventory.controller";

const router = Router();

router.get('/player-stats', inventoryController.getPlayerStats.bind(inventoryController));
router.get('/', inventoryController.getInventory.bind(inventoryController));
router.post('/battle-reward', inventoryController.claimBattleReward.bind(inventoryController));
router.post('/:id/upgrade', inventoryController.upgradeArtifact.bind(inventoryController));
router.post('/:id/upgrade-weapon', inventoryController.upgradeWeapon.bind(inventoryController));
router.post('/:id/reinforce', inventoryController.reinforceArtifact.bind(inventoryController));

export default router;
