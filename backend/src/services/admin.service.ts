import ShopRepository from "../repository/shop.repository";
import { prisma } from "../config/db";

import { CreateWeaponInput, CreateArtifactInput, UpdateWeaponInput, UpdateArtifactInput } from "../types/shop.types";
import { ServiceResponse } from "../types/response.types";

class AdminService {
    async getAllItems() {
        const weapons = await ShopRepository.findAllWeapons();
        const artifacts = await ShopRepository.findAllArtifacts();

        const weaponItems = weapons.map(weapon => ({
            id: weapon.weaponId,
            name: weapon.name,
            type: weapon.type,
            description: weapon.description,
            elementId: weapon.elementId,
            element: weapon.element?.type || null,
            stock: weapon.stock,
            imageUrl: weapon.imageUrl,
            price: Number(weapon.price),
            damage: weapon.damage,
            createdAt: weapon.createdAt,
            createdBy: weapon.createdBy,
            updatedAt: weapon.updatedAt,
            updatedBy: weapon.updatedBy
        }));

        const artifactItems = artifacts.map(artifact => ({
            id: artifact.artifactId,
            name: artifact.name,
            setName: artifact.setName,
            type: artifact.type,
            description: artifact.description,
            elementId: artifact.elementId,
            element: artifact.element?.type || null,
            stock: artifact.stock,
            imageUrl: artifact.imageUrl,
            price: Number(artifact.price),
            primaryStat: Number(artifact.primaryStat),
            secondaryStat: Number(artifact.secondaryStat),
            createdAt: artifact.createdAt,
            createdBy: artifact.createdBy,
            updatedAt: artifact.updatedAt,
            updatedBy: artifact.updatedBy
        }));

        return [...weaponItems, ...artifactItems];
    }

    async createItem(data: any, createdBy: string): Promise<ServiceResponse> {
        if (!data.name || !data.type || !data.description || !data.elementId ||
            data.stock === undefined || !data.imageUrl || data.price === undefined) {
            return {
                data: null,
                message: 'Invalid item data',
                statusCode: 400
            };
        }

        if (data.type === 'Weapon') {
            if (data.damage === undefined) {
                return {
                    data: null,
                    message: 'Invalid item data',
                    statusCode: 400
                };
            }

            const weaponData: CreateWeaponInput = {
                name: data.name,
                type: data.type,
                description: data.description,
                elementId: data.elementId,
                stock: data.stock,
                imageUrl: data.imageUrl,
                price: data.price,
                damage: data.damage
            };

            const weapon = await ShopRepository.createWeapon(weaponData, createdBy);

            return {
                data: {
                    id: weapon.weaponId,
                    name: weapon.name,
                    type: weapon.type,
                    description: weapon.description,
                    elementId: weapon.elementId,
                    stock: weapon.stock,
                    imageUrl: weapon.imageUrl,
                    price: Number(weapon.price),
                    damage: weapon.damage
                },
                message: 'Item created successfully',
                statusCode: 200
            };
        } else if (data.type === 'Artifact') {
            if (data.primaryStat === undefined || data.secondaryStat === undefined) {
                return {
                    data: null,
                    message: 'Invalid item data',
                    statusCode: 400
                };
            }

            const artifactData: CreateArtifactInput = {
                name: data.name,
                type: data.type,
                description: data.description,
                elementId: data.elementId,
                stock: data.stock,
                imageUrl: data.imageUrl,
                price: data.price,
                primaryStat: data.primaryStat,
                secondaryStat: data.secondaryStat
            };

            const artifact = await ShopRepository.createArtifact(artifactData, createdBy);

            return {
                data: {
                    id: artifact.artifactId,
                    name: artifact.name,
                    type: artifact.type,
                    description: artifact.description,
                    elementId: artifact.elementId,
                    stock: artifact.stock,
                    imageUrl: artifact.imageUrl,
                    price: Number(artifact.price),
                    primaryStat: Number(artifact.primaryStat),
                    secondaryStat: Number(artifact.secondaryStat)
                },
                message: 'Item created successfully',
                statusCode: 200
            };
        }

        return {
            data: null,
            message: 'Invalid item data',
            statusCode: 400
        };
    }

    async updateItem(id: number, data: any, updatedBy: string): Promise<ServiceResponse> {
        if (data.type === 'Weapon') {
            const existing = await ShopRepository.findWeaponById(id);

            if (!existing) {
                return {
                    data: null,
                    message: 'Item not found',
                    statusCode: 404
                };
            }

            const updateData: UpdateWeaponInput = {};
            if (data.name !== undefined) updateData.name = data.name;
            if (data.type !== undefined) updateData.type = data.type;
            if (data.description !== undefined) updateData.description = data.description;
            if (data.elementId !== undefined) updateData.elementId = data.elementId;
            if (data.stock !== undefined) updateData.stock = data.stock;
            if (data.imageUrl !== undefined) updateData.imageUrl = data.imageUrl;
            if (data.price !== undefined) updateData.price = data.price;
            if (data.damage !== undefined) updateData.damage = data.damage;

            const weapon = await ShopRepository.updateWeapon(id, updateData, updatedBy);

            return {
                data: {
                    id: weapon.weaponId,
                    name: weapon.name,
                    type: weapon.type,
                    description: weapon.description,
                    elementId: weapon.elementId,
                    stock: weapon.stock,
                    imageUrl: weapon.imageUrl,
                    price: Number(weapon.price),
                    damage: weapon.damage
                },
                message: 'Item updated successfully',
                statusCode: 200
            };
        } else if (data.type === 'Artifact') {
            const existing = await ShopRepository.findArtifactById(id);

            if (!existing) {
                return {
                    data: null,
                    message: 'Item not found',
                    statusCode: 404
                };
            }

            const updateData: UpdateArtifactInput = {};
            if (data.name !== undefined) updateData.name = data.name;
            if (data.type !== undefined) updateData.type = data.type;
            if (data.description !== undefined) updateData.description = data.description;
            if (data.elementId !== undefined) updateData.elementId = data.elementId;
            if (data.stock !== undefined) updateData.stock = data.stock;
            if (data.imageUrl !== undefined) updateData.imageUrl = data.imageUrl;
            if (data.price !== undefined) updateData.price = data.price;
            if (data.primaryStat !== undefined) updateData.primaryStat = data.primaryStat;
            if (data.secondaryStat !== undefined) updateData.secondaryStat = data.secondaryStat;

            const artifact = await ShopRepository.updateArtifact(id, updateData, updatedBy);

            return {
                data: {
                    id: artifact.artifactId,
                    name: artifact.name,
                    type: artifact.type,
                    description: artifact.description,
                    elementId: artifact.elementId,
                    stock: artifact.stock,
                    imageUrl: artifact.imageUrl,
                    price: Number(artifact.price),
                    primaryStat: Number(artifact.primaryStat),
                    secondaryStat: Number(artifact.secondaryStat)
                },
                message: 'Item updated successfully',
                statusCode: 200
            };
        }

        return {
            data: null,
            message: 'Invalid item type',
            statusCode: 400
        };
    }

    async deleteItem(id: number, itemType: string): Promise<ServiceResponse> {
        if (itemType === 'Weapon') {
            const existing = await ShopRepository.findWeaponById(id);

            if (!existing) {
                return {
                    message: 'Item not found',
                    statusCode: 404
                };
            }

            await ShopRepository.deleteWeapon(id);
        } else if (itemType === 'Artifact') {
            const existing = await ShopRepository.findArtifactById(id);

            if (!existing) {
                return {
                    message: 'Item not found',
                    statusCode: 404
                };
            }

            await ShopRepository.deleteArtifact(id);
        } else {
            return {
                message: 'Invalid item type',
                statusCode: 400
            };
        }

        return {
            message: 'Item deleted successfully',
            statusCode: 200
        };
    }

    // ── Enemy CRUD ────────────────────────────────────────────────────────────

    async getAllEnemies() {
        const enemies = await prisma.msEnemy.findMany({
            include: { element: true },
            orderBy: { enemyId: 'asc' }
        });
        return enemies.map(e => ({
            enemyId: e.enemyId,
            elementId: e.elementId,
            element: e.element?.type || null,
            name: e.name,
            type: e.type,
            imageUrl: e.imageUrl,
            hp: e.hp,
            damage: e.damage
        }));
    }

    async createEnemy(data: any, createdBy: string): Promise<ServiceResponse> {
        if (!data.name || !data.type || !data.elementId || data.hp === undefined || data.damage === undefined) {
            return { data: null, message: 'Invalid enemy data', statusCode: 400 };
        }
        const enemy = await prisma.msEnemy.create({
            data: {
                elementId: Number(data.elementId),
                name: data.name,
                type: data.type,
                imageUrl: data.imageUrl || '',
                hp: Number(data.hp),
                damage: Number(data.damage),
                createdAt: new Date(),
                createdBy,
                updatedAt: new Date(),
                updatedBy: createdBy
            }
        });
        return {
            data: { enemyId: enemy.enemyId, elementId: enemy.elementId, name: enemy.name, type: enemy.type, imageUrl: enemy.imageUrl, hp: enemy.hp, damage: enemy.damage },
            message: 'Enemy created successfully',
            statusCode: 200
        };
    }

    async updateEnemy(id: number, data: any, updatedBy: string): Promise<ServiceResponse> {
        const existing = await prisma.msEnemy.findUnique({ where: { enemyId: id } });
        if (!existing) return { data: null, message: 'Enemy not found', statusCode: 404 };

        const enemy = await prisma.msEnemy.update({
            where: { enemyId: id },
            data: {
                ...(data.elementId !== undefined && { elementId: Number(data.elementId) }),
                ...(data.name !== undefined && { name: data.name }),
                ...(data.type !== undefined && { type: data.type }),
                ...(data.imageUrl !== undefined && { imageUrl: data.imageUrl }),
                ...(data.hp !== undefined && { hp: Number(data.hp) }),
                ...(data.damage !== undefined && { damage: Number(data.damage) }),
                updatedAt: new Date(),
                updatedBy
            }
        });
        return {
            data: { enemyId: enemy.enemyId, elementId: enemy.elementId, name: enemy.name, type: enemy.type, imageUrl: enemy.imageUrl, hp: enemy.hp, damage: enemy.damage },
            message: 'Enemy updated successfully',
            statusCode: 200
        };
    }

    async deleteEnemy(id: number): Promise<ServiceResponse> {
        const existing = await prisma.msEnemy.findUnique({ where: { enemyId: id } });
        if (!existing) return { message: 'Enemy not found', statusCode: 404 };
        await prisma.msEnemy.delete({ where: { enemyId: id } });
        return { message: 'Enemy deleted successfully', statusCode: 200 };
    }
}

export default new AdminService();
