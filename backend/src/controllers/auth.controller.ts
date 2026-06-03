import { Request, Response } from 'express';

import authService from '../services/auth.service';
import { handleError } from '../utils/request.util';
import { SafeUserDataDTO } from '../types/auth.types';

class AuthController{
    async login(req: Request, res: Response): Promise<any> {
        try {
            
            const userData = {
                email: req.body.email,
                password: req.body.password
            }

            const user = await authService.login(userData)

            if (!user.data) {
                return res.status(409).json({
                    status: 'fail',
                    message: user.message,
                    data: null,
                    error: null
                }) 
            }

            const responseData : SafeUserDataDTO = {
                id: user.data.userId,
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
            
            res.status(500).json({
                status: 'error',
                message: 'Failed to login user',
                data: null,
                error: err.message
            })
        }
    }

    async register(req: Request, res: Response): Promise<any>{
        try {
            const userData = {
                email: req.body.email,
                name: req.body.name,
                password: req.body.password
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
                id: user.data.userId,
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
            
            res.status(500).json({
                status: 'error',
                message: 'Failed to register user',
                data: null,
                error: err.message
            });
        }
    }

    async googleLogin(req: Request, res: Response): Promise<any> {
        try {
            const { idToken, accessToken } = req.body;
            if (!idToken && !accessToken) {
                return res.status(400).json({ status: 'fail', message: 'idToken or accessToken is required', data: null, error: null });
            }

            const result = await authService.googleLogin(idToken, accessToken);

            if (!result.data) {
                return res.status(401).json({ status: 'fail', message: result.message, data: null, error: null });
            }

            const responseData: SafeUserDataDTO = {
                id: result.data.userId,
                email: result.data.email,
                name: result.data.name,
                role: result.data.role,
            };

            res.status(200).json({
                status: 'success',
                message: result.message,
                data: { user: responseData, token: result.token },
                error: null,
            });
        } catch (error) {
            const err = handleError(error);
            res.status(500).json({ status: 'error', message: 'Google login failed', data: null, error: err.message });
        }
    }
}

export default new AuthController();