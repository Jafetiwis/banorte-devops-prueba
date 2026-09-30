const express = require('express');
const app = express();
const port = 8080;

app.get('/', (req, res) => {
    const date = new Date();
    const nombre = process.env.NOMBRE || 'Jafet Alberto Vicencio';
    const mensaje = `Aplicación funcionando. Nombre: ${nombre}, Fecha: ${date}`;
    
    console.log(mensaje);
    res.send(mensaje);
});

app.listen(port, () => {
    console.log(`Aplicación escuchando en http://localhost:${port}`);
});