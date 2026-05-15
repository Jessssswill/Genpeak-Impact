import { prisma } from "../config/db";

import { CreateWeaponInput, CreateArtifactInput, UpdateWeaponInput, UpdateArtifactInput } from "../types/shop.types";

class ShopRepository {
    async findAllWeapons() {
        const weapons = await prisma.msWeapon.findMany({
            include: {
                element: true
            }
        });

        return weapons;
    }

    async findAllArtifacts() {
        const artifacts = await prisma.msArtifact.findMany({
            include: {
                element: true
            }
        });

        return artifacts;
    }

    async findWeaponById(id: number) {
        const weapon = await prisma.msWeapon.findUnique({
            where: { weaponId: id },
            include: { element: true }
        });

        return weapon;
    }

    async findArtifactById(id: number) {
        const artifact = await prisma.msArtifact.findUnique({
            where: { artifactId: id },
            include: { element: true }
        });

        return artifact;
    }

    async createWeapon(data: CreateWeaponInput, createdBy: string) {
        const weapon = await prisma.msWeapon.create({
            data: {
                name: data.name,
                type: data.type,
                description: data.description,
                elementId: data.elementId,
                stock: data.stock,
                imageUrl: data.imageUrl,
                price: data.price,
                damage: data.damage,
                createdAt: new Date(),
                createdBy: createdBy,
                updatedAt: new Date(),
                updatedBy: createdBy
            }
        });

        return weapon;
    }

    async createArtifact(data: CreateArtifactInput, createdBy: string) {
        const artifact = await prisma.msArtifact.create({
            data: {
                name: data.name,
<<<<<<< HEAD
=======
                setName: data.name, // Fallback to name if not provided
>>>>>>> 6b12a73 (update)
                type: data.type,
                description: data.description,
                elementId: data.elementId,
                stock: data.stock,
                imageUrl: data.imageUrl,
                price: data.price,
                primaryStat: data.primaryStat,
                secondaryStat: data.secondaryStat,
                createdAt: new Date(),
                createdBy: createdBy,
                updatedAt: new Date(),
                updatedBy: createdBy
            }
        });

        return artifact;
    }

    async updateWeapon(id: number, data: UpdateWeaponInput, updatedBy: string) {
        const weapon = await prisma.msWeapon.update({
            where: { weaponId: id },
            data: {
                ...data,
                updatedAt: new Date(),
                updatedBy: updatedBy
            }
        });

        return weapon;
    }

    async updateArtifact(id: number, data: UpdateArtifactInput, updatedBy: string) {
        const artifact = await prisma.msArtifact.update({
            where: { artifactId: id },
            data: {
                ...data,
                updatedAt: new Date(),
                updatedBy: updatedBy
            }
        });

        return artifact;
    }

    async deleteWeapon(id: number) {
        await prisma.msWeapon.delete({
            where: { weaponId: id }
        });
    }

    async deleteArtifact(id: number) {
        await prisma.msArtifact.delete({
            where: { artifactId: id }
        });
    }

    async decrementWeaponStock(id: number) {
        const weapon = await prisma.msWeapon.update({
            where: { weaponId: id },
            data: {
                stock: { decrement: 1 },
                updatedAt: new Date()
            }
        });

        return weapon;
    }

    async decrementArtifactStock(id: number) {
        const artifact = await prisma.msArtifact.update({
            where: { artifactId: id },
            data: {
                stock: { decrement: 1 },
                updatedAt: new Date()
            }
        });

        return artifact;
    }
}

export default new ShopRepository();