import { prisma } from "../config/db";
import { LoginUser } from "../types/userLogin.types";

class UserLoginService {
    async login(userData: { email: string }): Promise<{ data: LoginUser | null }> {
        const existingUser = await prisma.msUser.findUnique({
            where: {
                email: userData.email
            }
        });

        return {
            data: existingUser
        }
    }
}

export default new UserLoginService();