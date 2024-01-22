import express from 'express'
import http from 'http'
import {Server} from 'socket.io'
import {getQuery, storeMessage, getFriends, getChatRoom, createChat} from './database.js'

//const express = require('express');
const app = express();

//const httpServer = require('http').createServer(app);
const httpServer = http.createServer(app);
//const { Server } = require("socket.io");


const IO = new Server(httpServer);

const messages = []

IO.on('connection', (socket) => {
	const username = socket.handshake.query.username
  console.log(username, "connected")

  socket.on('message', (data) => {
    const message = {
      message: data.message,
      senderUsername: username,
      receiverUsername: data.receiver,
      sentAt: Date.now()
    };
    console.log(message);
    storeMessage(message);
    messages.push(message);
    IO.to(data.chatroom).emit('message', message)
  })

  socket.on('join', (room) => {
    console.log('Joining room: ' + room)
    socket.join(room);
    console.log(socket.rooms);
  })

  socket.on('leave', (room) => {
    console.log('Leaving room: ' + room)
    socket.leave(room);
    console.log(socket.rooms);
  })

  socket.on('friends', async (user) => {
    console.log('fetching friends of: ' + user);
    const result = await getFriends(user);
    IO.to(user).emit('friends', result);
  })

  socket.on('chat', async (users) => {
  console.log("Joining Chat with " + users.User2);
  const result = await getChatRoom(users);
  IO.to(users.User1).emit('chat', result);
  })

  socket.on('createChat', async (users) => {
    console.log("Creating chat room with" + users.User2);
    const result = await createChat(users)
    IO.to(users.User1).emit('chatCreated', result);
    })
});

httpServer.listen(3000, () => {
	console.log('listening on *:3000');
});

/*
httpServer.listen(3000, '0.0.0.0', () => {
  console.log('Listening to port: ' + 3000);
});
*/
