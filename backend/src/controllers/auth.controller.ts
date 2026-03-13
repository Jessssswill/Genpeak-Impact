import { Request, Response } from 'express';

import authService from '../services/auth.service';
import { handleError } from '../utils/request.util';
import { SafeUserDataDTO } from '../types/auth.types';

class AuthController{
    async login(req: Request, res: Response): Promise<any> {
        try {
            
            const userData = {
                email: req.user!.email,
                password: req.user!.password
            }

            const user = await authService.login(userData)

            if (!user.data) {
                return res.status(401).json({
                    status: 'fail',
                    message: user.message,
                    data: null,
                    error: null
                }) 
            }

            const responseData : SafeUserDataDTO = {
                userId: user.data.userId,
                email: user.data.email,
                name: user.data.name,
                role: user.data.role
            }

            res.status(200).json({ 
                status: 'success',
                message: user.message,
                data: {
                    user: responseData,
                    token: user.token
                },
                error: null
            })
            
        } catch (error) {
            const err = handleError(error)
            console.log('Error logging in user: ', err)
            res.status(500).json({
                status: 'error',
                message: 'failed to login user',
                data: null,
                error: err.message
            })
        }
    }

    async register(req: Request, res: Response): Promise<any>{
        try {
            const userData = {
                email: req.user!.email,
                name: req.user!.name,
                password: req.user!.password
            }

            const user = await authService.register(userData)

            if (!user.data) {
                res.status(401).json({
                    status: 'fail',
                    message: user.message,
                    data: null,
                    error: null
                }) 
                return
            }

            const responseData : SafeUserDataDTO = {
                userId: user.data.userId,
                email: user.data.email,
                name: user.data.name,
                role: user.data.role
            }

            res.status(200).json({
                status: 'success',
                message: user.message,
                data: responseData,
                error: null
            })
            
        } catch (error) {
            const err = handleError(error)
            console.log('Error registering user: ', err)
            res.status(500).json({
                status: 'error',
                message: 'failed to register user',
                data: null,
                error: err.message
            });
        }
    }
}

export default new AuthController();