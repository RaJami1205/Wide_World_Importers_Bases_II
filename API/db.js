const sql = require('mssql');

const config = {
  user: 'sa',
  password: 'Otp270905',
  server: '172.24.233.41', // o IP de tu servidor
  database: 'WideWorldImporters',
  options: {
    encrypt: false, // true si usas Azure
    trustServerCertificate: true,
    enableArithAbort: true
  }
};

module.exports = config;