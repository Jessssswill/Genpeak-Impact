import { prisma } from "../config/db";

class ItemRepository {
  async findAllElements() {
    return prisma.msElement.findMany({
      orderBy: { elementId: "asc" },
    });
  }

  async findAllWeapons() {
    return prisma.msWeapon.findMany({
      include: { element: true },
      orderBy: { weaponId: "asc" },
    });
  }

  async findWeaponById(id: number) {
    return prisma.msWeapon.findUnique({
      where: { weaponId: id },
      include: { element: true },
    });
  }

  async createWeapon(data: {
    elementId: number;
    name: string;
    type: string;
    description: string;
    stock: number;
    imageUrl: string;
    price: number;
    damage: number;
    userId?: string;
  }) {
    return prisma.msWeapon.create({
      data: {
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
        createdBy: data.userId || "SYSTEM",
      },
    });
  }

  async updateWeapon(
    id: number,
    data: {
      elementId?: number;
      name?: string;
      type?: string;
      description?: string;
      stock?: number;
      imageUrl?: string;
      price?: number;
      damage?: number;
      userId?: string;
    }
  ) {
    const { userId, ...updateData } = data;
    return prisma.msWeapon.update({
      where: { weaponId: id },
      data: {
        ...updateData,
        updatedAt: new Date(),
        updatedBy: userId || "SYSTEM",
      },
    });
  }

  async deleteWeapon(id: number) {
    return prisma.msWeapon.delete({ where: { weaponId: id } });
  }

  async findAllArtifacts() {
    return prisma.msArtifact.findMany({
      include: { element: true },
      orderBy: { artifactId: "asc" },
    });
  }

  async findArtifactById(id: number) {
    return prisma.msArtifact.findUnique({
      where: { artifactId: id },
      include: { element: true },
    });
  }

  async createArtifact(data: {
    elementId: number;
    name: string;
    setName: string;
    type: string;
    description: string;
    stock: number;
    imageUrl: string;
    price: number;
    primaryStat: number;
    secondaryStat: number;
    userId?: string;
  }) {
    return prisma.msArtifact.create({
      data: {
        ...data,
        createdAt: new Date(),
        updatedAt: new Date(),
        createdBy: data.userId || "SYSTEM",
      },
    });
  }

  async updateArtifact(
    id: number,
    data: {
      elementId?: number;
      name?: string;
      setName?: string;
      type?: string;
      description?: string;
      stock?: number;
      imageUrl?: string;
      price?: number;
      primaryStat?: number;
      secondaryStat?: number;
      userId?: string;
    }
  ) {
    const { userId, ...updateData } = data;
    return prisma.msArtifact.update({
      where: { artifactId: id },
      data: {
        ...updateData,
        updatedAt: new Date(),
        updatedBy: userId || "SYSTEM",
      },
    });
  }

  async deleteArtifact(id: number) {
    return prisma.msArtifact.delete({ where: { artifactId: id } });
  }

  async findAllEnemies() {
    return prisma.msEnemy.findMany({
      include: { element: true },
      orderBy: { enemyId: "asc" },
    });
  }
}

export default new ItemRepository();
