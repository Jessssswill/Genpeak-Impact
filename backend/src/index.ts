import express from "express";
import cors from 'cors';
import dotenv from 'dotenv'

import authRoutes from "./routes/auth.route"


dotenv.config()

const app = express()
const port = 5000

app.use(cors());
app.use(express.json());

app.get('/api/auth', authRoutes)

app.listen(port, () => {
    console.log(`listening on port ${port}`)
})