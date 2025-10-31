const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../db');

// Obtener clientes filtrados
router.get('/', async (req, res) => {
  const { Nombre, Categoria, MetodoEntrega } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre || null)
      .input('Categoria', sql.NVarChar(100), Categoria || null)
      .input('MetodoEntrega', sql.NVarChar(100), MetodoEntrega || null)
      .execute('ObtenerClientes');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en ObtenerClientes:', err);
    res.status(500).send('Error en la base de datos');
  }
});

// Información de un cliente específico
router.get('/info', async (req, res) => {
  const { Nombre } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre)
      .execute('InformacionCliente');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en InformacionCliente:', err);
    res.status(500).send('Error en la base de datos');
  }
});

module.exports = router;
