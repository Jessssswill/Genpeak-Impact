export interface ItemTransactionParams {
    userId: string;
    itemId: number;
    itemType: string;
}

export interface ItemCreationParams extends ItemTransactionParams {
    createdBy: string;
    level?: number;
    mainStatValue?: number;
    substats?: any;
}

export interface PurchaseCreationParams extends ItemCreationParams {
    money: number;
}
