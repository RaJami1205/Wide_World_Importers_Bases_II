const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../db');

router.get('/', async (req, res) => {
  const { Nombre, Categoria, MetodoEntrega } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre || null)
      .input('Categoria', sql.NVarChar(100), Categoria || null)
      .input('MetodoEntrega', sql.NVarChar(100), MetodoEntrega || null)
      .execute('ObtenerProveedores');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en ObtenerProveedores:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/info', async (req, res) => {
  const { Nombre } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre)
      .execute('InformacionProveedor');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en InformacionProveedor:', err);
    res.status(500).send('Error en la base de datos');
  }
});

module.exports = router;
