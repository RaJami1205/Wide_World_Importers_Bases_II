const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../db');

router.get('/', async (req, res) => {
  const { NumeroFactura, NombreCliente, FechaInicial, FechaFinal, MontoMinimo, MontoMaximo } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('NumeroFactura', sql.Int, NumeroFactura || null)
      .input('NombreCliente', sql.NVarChar(100), NombreCliente || null)
      .input('FechaInicial', sql.Date, FechaInicial || null)
      .input('FechaFinal', sql.Date, FechaFinal || null)
      .input('MontoMinimo', sql.Decimal(10,2), MontoMinimo || null)
      .input('MontoMaximo', sql.Decimal(10,2), MontoMaximo || null)
      .execute('ObtenerVentas');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en ObtenerVentas:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/info', async (req, res) => {
  const { NumeroFactura } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('NumeroFactura', sql.Int, NumeroFactura)
      .execute('InformacionVentas');

    res.json(result.recordsets);
  } catch (err) {
    console.error('Error en InformacionVentas:', err);
    res.status(500).send('Error en la base de datos');
  }
});

module.exports = router;
