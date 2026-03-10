import { prisma } from "../config/db";
import { RegisterUser } from "../types/userRegister.types";

class UserRegisterService {
    async register(userData: { email: string, name: string, password: string }): Promise<{ data: RegisterUser }>{

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

        return {
            data: newUser
        }
    }
}

export default new UserRegisterService();