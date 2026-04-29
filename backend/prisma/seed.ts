import { PrismaClient } from "../generated/prisma/client";
import { PrismaMariaDb } from "@prisma/adapter-mariadb";
import bcrypt from "bcryptjs";
import "dotenv/config";

const adapter = new PrismaMariaDb({
    host: process.env.DATABASE_HOST,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    database: process.env.DATABASE_NAME,
    connectionLimit: 5,
});

const prisma = new PrismaClient({ adapter });

async function main() {
    const adminEmail = "Admin@gmail.com";

    const existingAdmin = await prisma.msUser.findUnique({
        where: { email: adminEmail }
    });

    if (existingAdmin) {
        console.log(`Admin account already exists (${adminEmail}), skipping seed.`);
        return;
    }

    const hashedPassword = await bcrypt.hash("Admin", 10);

    const admin = await prisma.msUser.create({
        data: {
            email: adminEmail,
            name: "Admin",
            password: hashedPassword,
            role: "ADMIN",
            createdAt: new Date(),
            createdBy: "SYSTEM",
            updatedAt: new Date(),
            updatedBy: "SYSTEM"
        }
    });
}

main()
    .catch((e) => {
        console.error("Seed failed:", e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
