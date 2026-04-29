# Backend API Endpoints

## Authentication Endpoints

### `POST /api/auth/login`

#### Request Body

email: string
password: string

**Example Request:**

```json
{
    "email": "user1@example.com",
    "password": "user123456789"
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Login successful",
    "data": {
        "user": {
        "id": "user1",
        "email": "user1@example.com",
        "name": "user 1",
        "role": "USER"
        },
        "token": "asdasdasdasdasdasdasd"
    },
    "error": null
}
```

401 Unauthorized

```JSON
{
    "status": "fail",
    "message": "Invalid email or password",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to login user",
    "data": null,
    "error": "Database connection refused"
}
```

### `POST /api/auth/register`

#### Request Body

email: string
name: string
password: string

**Example Request:**

```json
{
    "email": "user1@example.com",
    "name": "user 1",
    "password": "user123456789"
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "User created succesfully",
    "data": {
        "id": "user1",
        "email": "user1@example.com",
        "name": "user 1",
        "role": "USER"
    },
    "error": null
}
```

409 Conflict

```JSON
{
    "status": "fail",
    "message": "User already exist",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "failed to register user",
    "data": null,
    "error": "Database connection refused"
}
```

## Shop Endpoints

### `GET /api/user/shop`

view all item in shop

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Items fetched successfully",
    "data": [
        {
            "id": 1,
            "name": "Aqua Sword",
            "type": "Weapon",
            "description": "A sword infused with water element",
            "element": "Water",
            "stock": 10,
            "imageUrl": "https://example.com/aqua-sword.png",
            "price": 1500,
            "damage": 120
        },
        {
            "id": 2,
            "name": "Crimson flames",
            "type": "Artifact",
            "description": "A crown burning with eternal flame",
            "element": "Fire",
            "stock": 5,
            "imageUrl": "https://example.com/crimson-flames.png",
            "price": 2000,
            "primaryStat": 15.5,
            "secondaryStat": 8.2
        }
    ],
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to fetch shop items",
    "data": null,
    "error": "Database connection refused"
}
```

### `POST /api/user/shop/:id`

buy item

#### Request Body

itemId: int

**Example Request:**

```json
{
    "itemId": 1
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Item purchased successfully",
    "data": {
        "purchaseId": 1,
        "userId": "user1",
        "itemId": 1,
        "itemType": "Weapon",
        "money": 1500
    },
    "error": null
}
```

400 Bad Request

```JSON
{
    "status": "fail",
    "message": "Insufficient money",
    "data": null,
    "error": null
}
```

404 Not Found

```JSON
{
    "status": "fail",
    "message": "Item not found",
    "data": null,
    "error": null
}
```

409 Conflict

```JSON
{
    "status": "fail",
    "message": "Item out of stock",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to purchase item",
    "data": null,
    "error": "Database connection refused"
}
```

## Inventory Endpoints

### `GET /api/user/inventory`

view item in inventory

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Inventory fetched successfully",
    "data": [
        {
            "inventoryId": 1,
            "itemId": 1,
            "itemType": "Weapon",
            "name": "Aqua Sword",
            "imageUrl": "https://example.com/aqua-sword.png"
        },
        {
            "inventoryId": 2,
            "itemId": 2,
            "itemType": "Artifact",
            "name": "Crimson Flames",
            "imageUrl": "https://example.com/fire-crown.png"
        }
    ],
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to fetch inventory",
    "data": null,
    "error": "Database connection refused"
}
```

## Admin Endpoints

### `GET /api/admin/shop`

view all item in admin panel

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Items fetched successfully",
    "data": [
        {
            "id": 1,
            "name": "Aqua Sword",
            "type": "Weapon",
            "description": "A sword infused with water element",
            "element": "Water",
            "stock": 10,
            "imageUrl": "https://example.com/aqua-sword.png",
            "price": 1500,
            "damage": 120,
            "createdAt": "2026-03-07T02:57:10.000Z",
            "createdBy": "admin",
            "updatedAt": "2026-03-07T02:57:10.000Z",
            "updatedBy": "admin"
        }
    ],
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to fetch shop items",
    "data": null,
    "error": "Database connection refused"
}
```

### `POST /api/admin/shop/item`

create new item in admin panel

#### Request Body

**weapon**

name: string
type: string
description: string
elementId: int
stock: int
imageUrl: string
price: decimal
damage: int

**artifact**

name: string
type: string
description: string
elementId: int
stock: int
imageUrl: string
price: decimal
primaryStat: decimal
secondaryStat: decimal

**Example Request:**

```json
{
    "name": "Aqua Sword",
    "type": "Weapon",
    "description": "A sword infused with water element",
    "elementId": 1,
    "stock": 10,
    "imageUrl": "https://example.com/aqua-sword.png",
    "price": 1500,
    "damage": 120
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Item created successfully",
    "data": {
        "id": 1,
        "name": "Aqua Sword",
        "type": "Weapon",
        "description": "A sword infused with water element",
        "elementId": 1,
        "stock": 10,
        "imageUrl": "https://example.com/aqua-sword.png",
        "price": 1500,
        "damage": 120
    },
    "error": null
}
```

400 Bad Request

```JSON
{
    "status": "fail",
    "message": "Invalid item data",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to create item",
    "data": null,
    "error": "Database connection refused"
}
```

### `PUT /api/admin/shop/item/:id`

update an item in admin panel

#### Request Body

**weapon**

name: string
type: string
description: string
elementId: int
stock: int
imageUrl: string
price: decimal
damage: int

**artifact**

name: string
type: string
description: string
elementId: int
stock: int
imageUrl: string
price: decimal
primaryStat: decimal
secondaryStat: decimal

**Example Request:**

```json
{
    "name": "Aqua Sword+",
    "type": "Weapon",
    "description": "An upgraded sword infused with water element",
    "elementId": 1,
    "stock": 5,
    "imageUrl": "https://example.com/aqua-sword-plus.png",
    "price": 3000,
    "damage": 200
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Item updated successfully",
    "data": {
        "id": 1,
        "name": "Aqua Sword+",
        "type": "Weapon",
        "description": "An upgraded sword infused with water element",
        "elementId": 1,
        "stock": 5,
        "imageUrl": "https://example.com/aqua-sword-plus.png",
        "price": 3000,
        "damage": 200
    },
    "error": null
}
```

404 Not Found

```JSON
{
    "status": "fail",
    "message": "Item not found",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to update item",
    "data": null,
    "error": "Database connection refused"
}
```

### `DELETE /api/admin/shop/item/:id`

delete an item in admin panel

#### Request Body

itemId: int

**Example Request:**

```json
{
    "itemId": 1
}
```

#### Responses

200 OK

```JSON
{
    "status": "success",
    "message": "Item deleted successfully",
    "data": null,
    "error": null
}
```

404 Not Found

```JSON
{
    "status": "fail",
    "message": "Item not found",
    "data": null,
    "error": null
}
```

500 Internal Server Error

```JSON
{
    "status": "error",
    "message": "Failed to delete item",
    "data": null,
    "error": "Database connection refused"
}
```


<!-- ### `GET /api/user/inventory/:id`

view detailed item attributes after clicking the item when on inventory -->

<!-- ### `POST /api/user/equip/:id` -->