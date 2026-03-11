import { Router } from "express";
import userRegisterController from "../controllers/userRegister.controller";

const router = Router();

router.post('/register', userRegisterController.register.bind(userRegisterController))

export default router;