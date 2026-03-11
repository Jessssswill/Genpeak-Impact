import { Request, Response } from 'express';
import userRegisterService from '../services/userRegister.service';
import { handleError } from '../utils/request.util';
import * as bcrypt from 'bcryptjs';

class UserRegisterController{
    async register(req: Request, res: Response): Promise<void>{
        try {
            const userPassword = await bcrypt.hash(req.user!.password, 10);

            const userData = {
                email: req.user!.email,
                name: req.user!.name,
                password: userPassword,
            }

            const user = await userRegisterService.register(userData)

            res.status(200).json({
                status: 'success',
                message: 'User created succesfully',
                data: user.data
            })
            
        } catch (error) {
            const err = handleError(error)
            console.log('Error registering user', err)
            res.status(500).json({
                status: 'error',
                message: 'failed to register user',
                error: err.message
            });
        }
    }
}

export default new UserRegisterController();