import * as bcrypt from "bcryptjs"
import jwt from 'jsonwebtoken'

import { AuthUser, CreateUserInput, SearchUserInput } from "../types/auth.types";
import UserRepository from "../repository/user.repository"

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

        const isMatch = await bcrypt.compare(existingUser.password, userData.password)

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

        return {
            data: newUser,
            message: 'User created succesfully'
        }
    }
}

export default new AuthService();