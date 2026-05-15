import express from "express";
import cors from 'cors';
import dotenv from 'dotenv';
<<<<<<< HEAD
=======
import path from 'path';
import { fileURLToPath } from 'url';
>>>>>>> 6b12a73 (update)

import authRoutes from "./routes/auth.route";
import adminRoutes from "./routes/admin.route";
import inventoryRoutes from "./routes/inventory.route";
import shopRoutes from "./routes/shop.route";
<<<<<<< HEAD
=======
import adminService from "./services/admin.service";
>>>>>>> 6b12a73 (update)

import { authenticate, authorizeAdmin } from "./middleware/auth.middleware";
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

dotenv.config();

<<<<<<< HEAD
=======
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

>>>>>>> 6b12a73 (update)
const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

<<<<<<< HEAD
=======
// Serve static images from public/images
const publicImagesPath = path.join(__dirname, '..', 'public', 'images');
app.use('/images', express.static(publicImagesPath));

// Public endpoint — no auth required (game data for all users)
app.get('/api/items/enemies', async (_req, res) => {
    try {
        const enemies = await adminService.getAllEnemies();
        res.json({ status: 'success', message: 'Enemies fetched', data: enemies, error: null });
    } catch {
        res.status(500).json({ status: 'error', message: 'Failed to fetch enemies', data: null, error: null });
    }
});

>>>>>>> 6b12a73 (update)
app.use('/api/auth', authRoutes);
app.use('/api/admin', authenticate, authorizeAdmin, adminRoutes);
app.use('/api/inventory', authenticate, inventoryRoutes);
app.use('/api/shop', authenticate, shopRoutes);

app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.listen(port, () => {
    console.log(`listening on port ${port}`);
});