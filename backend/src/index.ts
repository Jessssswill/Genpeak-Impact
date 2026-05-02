import express from "express";
import cors from 'cors';
import dotenv from 'dotenv';

import authRoutes from "./routes/auth.route";
import adminRoutes from "./routes/admin.route";
import inventoryRoutes from "./routes/inventory.route";
import shopRoutes from "./routes/shop.route";

import { authenticate, authorizeAdmin } from "./middleware/auth.middleware";

dotenv.config();

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/admin', authenticate, authorizeAdmin, adminRoutes);
app.use('/api/inventory', authenticate, inventoryRoutes);
app.use('/api/shop', authenticate, shopRoutes);

app.listen(port, () => {
    console.log(`listening on port ${port}`);
});