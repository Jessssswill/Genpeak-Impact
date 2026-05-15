import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

import { JwtPayload } from '../types/express';
import { handleError } from '../utils/request.util';

export function authenticate(req: Request, res: Response, next: NextFunction): void {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({
            status: 'fail',
            message: 'Access denied. No token provided',
            data: null,
            error: null
        });
        return;
    }

    const token = authHeader.split(' ')[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JwtPayload;

        req.jwtPayload = {
            id: decoded.id,
            role: decoded.role
        };

        next();
    } catch (error) {
        const err = handleError(error)
        console.log('Error registering user: ', err)
        res.status(401).json({
            status: 'fail',
            message: 'Invalid or expired token',
            data: null,
            error: err.message
        });
    }
}

export function authorizeAdmin(req: Request, res: Response, next: NextFunction): any {
    if (!req.jwtPayload || req.jwtPayload.role !== 'ADMIN') {
        return res.status(403).json({
            status: 'fail',
            message: 'Access denied. Admin privileges required',
            data: null,
            error: null
        });
    }

    next();
<<<<<<< HEAD
}
=======
}
>>>>>>> 6b12a73 (update)
