const express = require('express');
const router = express.Router();
const sql = require('mssql');
const config = require('../db');

router.get('/clientes', async (req, res) => {
  const { Cliente, Categoria } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Cliente', sql.NVarChar(100), Cliente || null)
      .input('Categoria', sql.NVarChar(100), Categoria || null)
      .execute('EstadisticasVentasClientes');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en EstadisticasVentasClientes:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/topclientes', async (req, res) => {
  const { AnioInicio, AnioFin } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('AnioInicio', sql.Int, AnioInicio || null)
      .input('AnioFin', sql.Int, AnioFin || null)
      .execute('Top5ClientesPorFacturas');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en Top5ClientesPorFacturas:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/proveedores', async (req, res) => {
  const { Nombre, Categoria } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('Nombre', sql.NVarChar(100), Nombre || null)
      .input('Categoria', sql.NVarChar(100), Categoria || null)
      .execute('EstadisticaProveedores');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en EstadisticaProveedores:', err);
    res.status(500).send('Error en la base de datos');
  }
});

router.get('/topproveedores', async (req, res) => {
  const { AnioInicio, AnioFin } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('AnioInicio', sql.Int, AnioInicio || null)
      .input('AnioFin', sql.Int, AnioFin || null)
      .execute('Top5ProveedoresPorOrdenes');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en Top5ProveedoresPorOrdenes:', err);
    res.status(500).send('Error en la base de datos');
  }
});


router.get('/productos', async (req, res) => {
  const { AnioInicio, AnioFin } = req.query;

  try {
    let pool = await sql.connect(config);
    let result = await pool.request()
      .input('AnioInicio', sql.Int, AnioInicio || null)
      .input('AnioFin', sql.Int, AnioFin || null)
      .execute('Top5ProductosPorGanancia');

    res.json(result.recordset);
  } catch (err) {
    console.error('Error en Top5ProductosPorGanancia:', err);
    res.status(500).send('Error en la base de datos');
  }
});

module.exports = router;
