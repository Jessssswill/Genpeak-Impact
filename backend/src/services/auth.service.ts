import * as bcrypt from "bcryptjs"
import jwt from 'jsonwebtoken'
import { OAuth2Client } from 'google-auth-library'
import crypto from 'crypto'

import { AuthUser, CreateUserInput, SearchUserInput } from "../types/auth.types";
import UserRepository from "../repository/user.repository"
import PlayerStatsRepository from "../repository/playerStats.repository"

class AuthService {
    async login(userData: SearchUserInput): Promise<{
        data: AuthUser | null,
        message: string,
        token: string | null
    }> {

        const existingUser = await UserRepository.findUser(userData.email);

        if (!existingUser) {
            return {
                data: null,
                message: 'User not found',
                token: null
            }
        }

        const isMatch = await bcrypt.compare(userData.password, existingUser.password)

        if (!isMatch) {
            return {
                data: null,
                message: 'Wrong password',
                token: null
            }
        }

        const payload = {
            id: existingUser.userId,
            role: existingUser.role
        }

        const token = jwt.sign(payload, process.env.JWT_SECRET!, {
            algorithm: 'HS256',
            expiresIn: '1h'
        })

        return {
            data: existingUser,
            message: 'Login successfull',
            token: token
        }
    }

    async register(userData: CreateUserInput): Promise<{
        data: AuthUser | null,
        message: string
    }>{

        const existingUser = await UserRepository.findUser(userData.email);

        if (existingUser) {
            return {
                data: null,
                message: 'User already exist',
            }
        }

        const hashedPassword = await bcrypt.hash(userData.password, 10);

        const CreateUserInput = {
            email: userData.email,
            name: userData.name,
            password: hashedPassword,
        }

        const newUser = await UserRepository.createUser(CreateUserInput)

        // Give starting stats and 500k Mora to the new user
        if (newUser) {
            await PlayerStatsRepository.createPlayerStats(newUser.userId, newUser.name);
        }

        return {
            data: newUser,
            message: 'User created succesfully'
        }
    }

    async googleLogin(idToken: string): Promise<{
        data: AuthUser | null,
        message: string,
        token: string | null
    }> {
        try {
            const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
            const ticket = await client.verifyIdToken({
                idToken,
                audience: process.env.GOOGLE_CLIENT_ID,
            });
            const payload = ticket.getPayload();
            if (!payload || !payload.email) {
                return { data: null, message: 'Invalid Google token', token: null };
            }

            let user = await UserRepository.findUser(payload.email);
            if (!user) {
                const randomPassword = await bcrypt.hash(crypto.randomUUID(), 10);
                const newUser = await UserRepository.createUser({
                    email: payload.email,
                    name: payload.name ?? payload.email.split('@')[0],
                    password: randomPassword,
                });
                if (newUser) {
                    await PlayerStatsRepository.createPlayerStats(newUser.userId, newUser.name);
                    user = newUser;
                }
            }

            if (!user) return { data: null, message: 'Failed to process Google account', token: null };

            const jwtPayload = { id: user.userId, role: user.role };
            const token = jwt.sign(jwtPayload, process.env.JWT_SECRET!, {
                algorithm: 'HS256',
                expiresIn: '1h',
            });

            return { data: user, message: 'Google login successful', token };
        } catch {
            return { data: null, message: 'Google token verification failed', token: null };
        }
    }
}

export default new AuthService();