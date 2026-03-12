import { Router } from "express";
import userLoginController from "../controllers/userLogin.controller";

const router = Router();

router.post('/login', userLoginController.login.bind(userLoginController))

export default router;