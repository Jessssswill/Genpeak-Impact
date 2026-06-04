import express from "express";
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
// Removed import.meta.url which breaks Vercel CommonJS builds
import authRoutes from "./routes/auth.route";
import adminRoutes from "./routes/admin.route";
import inventoryRoutes from "./routes/inventory.route";
import shopRoutes from "./routes/shop.route";
import adminService from "./services/admin.service";

import { authenticate, authorizeAdmin } from "./middleware/auth.middleware";
import swaggerUi from 'swagger-ui-express';
import { swaggerSpec } from './config/swagger';

dotenv.config();

// Using process.cwd() instead of __dirname
const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Serve static images from public/images
const publicImagesPath = path.join(process.cwd(), 'public', 'images');
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

app.use('/api/auth', authRoutes);
app.use('/api/admin', authenticate, authorizeAdmin, adminRoutes);
app.use('/api/inventory', authenticate, inventoryRoutes);
app.use('/api/shop', authenticate, shopRoutes);

app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

if (process.env.NODE_ENV !== 'production') {
    app.listen(port, () => {
        console.log(`listening on port ${port}`);
    });
}

export default app;
