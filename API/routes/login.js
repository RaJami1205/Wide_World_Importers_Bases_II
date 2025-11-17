const express = require('express');
const router = express.Router();
const { sql, connect } = require('../db');

// SIEMPRE trabajamos con el servidor corporativo
const SERVIDOR = 'corporativo';

router.post('/', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password)
      return res.status(400).json({ error: "Faltan credenciales" });

    await connect(SERVIDOR);

    const result = await sql.query(`
      SELECT iduser, username, fullname, rol, email, active
      FROM Usuarios
      WHERE username = '${username}' 
        AND password = '${password}'
    `);

    if (result.recordset.length === 0)
      return res.status(401).json({ error: "Usuario o contraseña incorrectos" });

    const user = result.recordset[0];

    if (user.active !== 1)
      return res.status(403).json({ error: "Usuario inactivo" });

    return res.json({
      id: user.iduser,
      username: user.username,
      fullname: user.fullname,
      email: user.email,
      rol: user.rol   // 0 = ADMIN, 1 = CORPORATIVO
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error interno en el servidor" });
  }
});

module.exports = router;