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

### `POST /api/user/shop/:id`

buy item

### `GET /api/user/shop`

view all item in shop

### `GET /api/user/inventory`

view item in inventory

### `GET /api/admin/shop`

view all item in admin panel

### `POST /api/admin/shop/item`

create new item in admin panel

### `PUT /api/admin/shop/item/:id`

update an item status on admin panel

### `DELETE /api/admin/shop/item/:id`

delete an item status on admin panel


<!-- ### `GET /api/user/inventory/:id`

view detailed item attributes after clicking the item when on inventory -->

<!-- ### `POST /api/user/equip/:id` -->