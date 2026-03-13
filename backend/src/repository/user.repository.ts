import { prisma } from "../config/db";

import { AuthUser, CreateUserInput } from "../types/auth.types";

class UserRepository{
    async findUser(email: string): Promise<AuthUser | null >{
        const existingUser = await prisma.msUser.findUnique({
                where: {
                    email: email
                }
        })
        
        return existingUser;
    }

    async createUser(userData: CreateUserInput): Promise<AuthUser | null> {
        const newUser = await prisma.msUser.create({
            data: {
                email: userData.email,
                name: userData.name,
                password: userData.password,
                role: "USER",
                createdAt: new Date(),
                createdBy: userData.name,
                updatedAt: new Date(),
                updatedBy: userData.name
            }
        })

        return newUser;
    }
}

export default new UserRepository();