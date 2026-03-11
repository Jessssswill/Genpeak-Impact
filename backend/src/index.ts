import express from "express";

import userRegisterRoutes from "./routes/userRegister.route"

const app = express()
const port = 5000

app.get('/api', userRegisterRoutes)

app.listen(port, () => {
    console.log(`listening on port ${port}`)
})