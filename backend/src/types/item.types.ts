export interface ItemTransactionParams {
    userId: string;
    itemId: number;
    itemType: string;
}

export interface ItemCreationParams extends ItemTransactionParams {
    createdBy: string;
<<<<<<< HEAD
=======
    level?: number;
    mainStatValue?: number;
    substats?: any;
>>>>>>> 6b12a73 (update)
}

export interface PurchaseCreationParams extends ItemCreationParams {
    money: number;
<<<<<<< HEAD
}
=======
}
>>>>>>> 6b12a73 (update)
