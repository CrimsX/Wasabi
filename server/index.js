import express from 'express'
import http from 'http'
import {Server} from 'socket.io'

//const express = require('express');
const app = express();

//const httpServer = require('http').createServer(app);
const httpServer = http.createServer(app);
//const { Server } = require("socket.io");


const IO = new Server(httpServer);

const messages = []

IO.on('connection', (socket) => {
	const username = socket.handshake.query.username
  console.log("User connected:", username)

  const active = new Set();
  active.add(username);
  
  io.emit("Active connections:", Array.from(active));

  socket.on('disconnect', () => {
    console.log("User disconnected:", username);
    active.delete(username);
    io.emit("Active connections:", Array.from(active));
  });

  socket.on('message', (data) => {
    const message = {
      message: data.message,
      senderUsername: username,
      sentAt: Date.now()
    }
    console.log(message)
    messages.push(message)
    IO.emit('message', message)
  });
});

httpServer.listen(3000, () => {
	console.log('Server is listening on *:3000');
});

/*
httpServer.listen(3000, '0.0.0.0', () => {
  console.log('Listening to port: ' + 3000);
});
*/

