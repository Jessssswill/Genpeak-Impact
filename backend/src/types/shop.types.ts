export interface ShopWeapon {
    weaponId: number
    elementId: number
    name: string
    type: string
    description: string
    stock: number
    imageUrl: string
    price: number | string
    damage: number
    element?: {
        name: string
        type: string
    }
    createdAt: Date
    createdBy: string | null
    updatedAt: Date
    updatedBy: string | null
}

export interface ShopArtifact {
    artifactId: number
    elementId: number
    name: string
    type: string
    description: string
    stock: number
    imageUrl: string
    price: number | string
    primaryStat: number | string
    secondaryStat: number | string
    element?: {
        name: string
        type: string
    }
    createdAt: Date
    createdBy: string | null
    updatedAt: Date
    updatedBy: string | null
}

export interface CreateWeaponInput {
    name: string
    type: string
    description: string
    elementId: number
    stock: number
    imageUrl: string
    price: number
    damage: number
}

export interface CreateArtifactInput {
    name: string
    type: string
    description: string
    elementId: number
    stock: number
    imageUrl: string
    price: number
    primaryStat: number
    secondaryStat: number
}

export interface UpdateWeaponInput {
    name?: string
    type?: string
    description?: string
    elementId?: number
    stock?: number
    imageUrl?: string
    price?: number
    damage?: number
}

export interface UpdateArtifactInput {
    name?: string
    type?: string
    description?: string
    elementId?: number
    stock?: number
    imageUrl?: string
    price?: number
    primaryStat?: number
    secondaryStat?: number
}

export interface InventoryItem {
    inventoryId: number
    itemId?: number
    itemType?: string
    itemCategory?: string
    name: string
    imageUrl: string
    level?: number
    mainStatValue?: number | null
    substats?: any
    [key: string]: any
}

export interface PurchaseResult {
    purchaseId: number
    userId: string
    itemId: number
    itemType: string
    money: number | string
}
