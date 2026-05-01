export interface ItemTransactionParams {
    userId: string;
    itemId: number;
    itemType: string;
}

export interface ItemCreationParams extends ItemTransactionParams {
    createdBy: string;
}

export interface PurchaseCreationParams extends ItemCreationParams {
    money: number;
}
