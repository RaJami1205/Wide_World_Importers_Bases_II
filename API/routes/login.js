const express = require('express');
const router = express.Router();
const { sql, connect } = require('../db');
const crypto = require('crypto');

// Función para hashear la contraseña igual que SQL Server (SHA2_512)
function hashPassword(password) {
  return crypto.createHash('sha512').update(password, 'utf8').digest();
}

const SERVIDOR = 'corporativo';

router.post('/', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password)
      return res.status(400).json({ error: "Faltan credenciales" });

    // Conectar al servidor Corporativo
    await connect(SERVIDOR);

    // Hashear contraseña ingresada
    const hashedPass = hashPassword(password);

    const request = new sql.Request();
    request.input("username", sql.NVarChar, username);
    request.input("password", sql.VarBinary, hashedPass);

    const result = await request.query(`
      SELECT iduser, username, fullname, rol, email, active
      FROM Usuarios
      WHERE username = @username
      AND password = @password;
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
      rol: user.rol  // 0 = ADMIN, 1 = CORPORATIVO
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error interno en el servidor" });
  }
});

module.exports = router;