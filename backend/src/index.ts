import express from "express";
import cors from 'cors';
import dotenv from 'dotenv'

import userRegisterRoutes from "./routes/userRegister.route"
import userLoginRoutes from "./routes/userLogin.route"

dotenv.config()

const app = express()
const port = 5000

app.use(cors());
app.use(express.json());

app.get('/api', userRegisterRoutes)
app.get('/api', userLoginRoutes)

app.listen(port, () => {
    console.log(`listening on port ${port}`)
})