const express = require('express');
const sql = require('mssql');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === "true",
        enableArithAbort: true,
        // When using a fixed port, remove instanceName if not needed
        // instanceName: process.env.DB_INSTANCE_NAME || "SQLEXPRESS"
    },
    port: Number(process.env.DB_PORT) || 1433
};

app.get('/CelestialBodies', async (req, res) => {
    try {
        const pool  = await sql.connect(config);
        const data = pool.request().query('SELECT * FROM CelestialBodies');
        data.then(result => {
        res.json(result);
    }
    )}
    catch (err) {
        console.log(err);
    }
})

app.get('/', async (req, res) => {
    return res.json("Server is running on port 3000.");
})

app.listen(3000, () => {
    console.log('Server is running on port 3000');
})