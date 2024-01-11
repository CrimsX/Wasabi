const express = require('express');
const app = express();

const httpServer = require('http').createServer(app);
const { Server } = require("socket.io");
const IO = new Server(httpServer);

IO.on('connection', (socket) => {
	console.log('a user connected');
});

httpServer.listen(3000, () => {
	console.log('listening on *:3000');
});
