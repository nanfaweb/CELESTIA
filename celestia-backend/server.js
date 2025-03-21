const express = require('express');
const sql = require('mssql');
const cors = require('cors');

const app = express();
app.use(cors());

require('dotenv').config();
const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_NAME,
    options: {
        trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === "true",
        enableArithAbort: true,
        instancename: process.env.DB_INSTANCE_NAME || "SQLEXPRESS"
    },
    port: process.env.DB_PORT || 1433
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