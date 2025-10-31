const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../db');

router.get('/', async (req, res) => {
  const { Nombre, Grupo, CantidadMinima, CantidadMaxima } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre || null)
      .input('Grupo', sql.NVarChar(100), Grupo || null)
      .input('CantidadMinima', sql.Int, CantidadMinima || null)
      .input('CantidadMaxima', sql.Int, CantidadMaxima || null)
      .execute('ObtenerInventarios');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en ObtenerInventarios:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/info', async (req, res) => {
  const { Nombre } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre)
      .execute('InformacionInventario');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en InformacionInventario:', err);
    res.status(500).send('Error en la base de datos');
  }
});

module.exports = router;
