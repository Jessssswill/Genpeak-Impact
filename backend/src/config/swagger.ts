import swaggerJsdoc from 'swagger-jsdoc';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'GenPeak-Impact Backend API',
      version: '1.0.0',
      description: 'API documentation for GenPeak-Impact backend',
    },
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        BearerAuth: [],
      },
    ],
    paths: {
      '/api/auth/login': {
        post: {
          summary: 'User login',
          tags: ['Authentication'],
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['email', 'password'],
                  properties: {
                    email: { type: 'string', example: 'user1@example.com' },
                    password: { type: 'string', example: 'user123456789' }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'Login successful' },
            401: { description: 'Invalid email or password' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/auth/register': {
        post: {
          summary: 'User registration',
          tags: ['Authentication'],
          security: [],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['email', 'name', 'password'],
                  properties: {
                    email: { type: 'string', example: 'user1@example.com' },
                    name: { type: 'string', example: 'user 1' },
                    password: { type: 'string', example: 'user123456789' }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'User created successfully' },
            409: { description: 'User already exist' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/user/shop': {
        get: {
          summary: 'View all items in shop',
          tags: ['Shop'],
          responses: {
            200: { description: 'Items fetched successfully' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/user/shop/{id}': {
        post: {
          summary: 'Buy an item',
          tags: ['Shop'],
          parameters: [
            {
              in: 'path',
              name: 'id',
              required: true,
              schema: { type: 'integer' }
            }
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['itemId'],
                  properties: {
                    itemId: { type: 'integer', example: 1 }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'Item purchased successfully' },
            400: { description: 'Insufficient money' },
            404: { description: 'Item not found' },
            409: { description: 'Item out of stock' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/user/inventory': {
        get: {
          summary: 'View items in inventory',
          tags: ['Inventory'],
          responses: {
            200: { description: 'Inventory fetched successfully' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/admin/shop': {
        get: {
          summary: 'View all items in admin panel',
          tags: ['Admin'],
          responses: {
            200: { description: 'Items fetched successfully' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/admin/shop/item': {
        post: {
          summary: 'Create a new item in admin panel',
          tags: ['Admin'],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    name: { type: 'string', example: 'Aqua Sword' },
                    type: { type: 'string', example: 'Weapon' },
                    description: { type: 'string', example: 'A sword infused with water element' },
                    elementId: { type: 'integer', example: 1 },
                    stock: { type: 'integer', example: 10 },
                    imageUrl: { type: 'string', example: 'https://example.com/aqua-sword.png' },
                    price: { type: 'number', example: 1500 },
                    damage: { type: 'integer', example: 120 },
                    primaryStat: { type: 'number' },
                    secondaryStat: { type: 'number' }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'Item created successfully' },
            400: { description: 'Invalid item data' },
            500: { description: 'Internal Server Error' }
          }
        }
      },
      '/api/admin/shop/item/{id}': {
        put: {
          summary: 'Update an item in admin panel',
          tags: ['Admin'],
          parameters: [
            {
              in: 'path',
              name: 'id',
              required: true,
              schema: { type: 'integer' }
            }
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    name: { type: 'string', example: 'Aqua Sword+' },
                    type: { type: 'string', example: 'Weapon' },
                    description: { type: 'string', example: 'An upgraded sword infused with water element' },
                    elementId: { type: 'integer', example: 1 },
                    stock: { type: 'integer', example: 5 },
                    imageUrl: { type: 'string', example: 'https://example.com/aqua-sword-plus.png' },
                    price: { type: 'number', example: 3000 },
                    damage: { type: 'integer', example: 200 },
                    primaryStat: { type: 'number' },
                    secondaryStat: { type: 'number' }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'Item updated successfully' },
            404: { description: 'Item not found' },
            500: { description: 'Internal Server Error' }
          }
        },
        delete: {
          summary: 'Delete an item in admin panel',
          tags: ['Admin'],
          parameters: [
            {
              in: 'path',
              name: 'id',
              required: true,
              schema: { type: 'integer' }
            }
          ],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    itemId: { type: 'integer', example: 1 }
                  }
                }
              }
            }
          },
          responses: {
            200: { description: 'Item deleted successfully' },
            404: { description: 'Item not found' },
            500: { description: 'Internal Server Error' }
          }
        }
      }
    }
  },
  apis: [], 
};

export const swaggerSpec = swaggerJsdoc(options);