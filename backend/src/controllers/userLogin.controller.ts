import { Request, Response } from 'express';
import jwt from 'jsonwebtoken'
import userLoginService from '../services/userLogin.service';

import * as bcrypt from "bcryptjs"
import { handleError } from '../utils/request.util';

class UserLoginController{
    async login(req: Request, res: Response): Promise< any > {
        try {
            const userData = {
                email: req.user!.email
            }

            const user = await userLoginService.login(userData)

            if (!user) {
                res.status(401).json({
                    status: 'failed',
                    message: 'User not found'
                }) 
                return
            }
            const isMatch = await bcrypt.compare(user.data!.password, req.user!.password)
        
            if (!isMatch) {
                res.status(401).json({
                    status: 'failed',
                    message: 'Wrong password',
                })
                return
            }

            const payload = {
                id: user.data!.userId,
                role: user.data!.role
            }

            const token = jwt.sign(payload, process.env.JWT_SECRET!, {
                algorithm: 'HS256',
                expiresIn: '1h'
            })

            res.status(200).json({
                status: 'success',
                message: 'Login successfull',
                token: token,
                data: user.data
            })
            
        } catch (error) {
            const err = handleError(error)
            console.log('Error registering user', err)
            res.status(500).json({
                status: 'error',
                message: 'failed to login user',
                error: err.message
            })
        }
    }
}

export default new UserLoginController();