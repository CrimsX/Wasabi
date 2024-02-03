import express from 'express'
import http from 'http'
import {Server} from 'socket.io'
import {
  storeMessage,
  getFriends,
  getChatRoom,
  createChat,
  fetchChat,
  addFriend,
  getServers,
  storeGroupMessage,
  fetchGroupChat
} from './database.js'

const app = express();
const httpServer = http.createServer(app);
const IO = new Server(httpServer);
const messages = []

IO.on('connection', (socket) => {
	const username = socket.handshake.query.username
  console.log("User connected:", username)

  const active = new Set();
  active.add(username);

  IO.emit("Active connections:", Array.from(active));

  socket.on('disconnect', () => {
    console.log("User disconnected:", username);
    active.delete(username);
    IO.emit("Active connections:", Array.from(active));
  });

  /**
   * when 'message' emitted from client, creates JSON object containing message info,
   * stores message info to db, and emits it back to the chat to both users in chat room.
   */
  socket.on('message', (data) => {
    const message = {
      message: data.message,
      senderUsername: username,
      receiverUsername: data.receiver,
      sentAt: Date.now(),
      chatID: parseInt(data.chatroom, 10)
    };
    console.log(message);
    storeMessage(message);
    messages.push(message);
    IO.to(data.chatroom).emit('message', message)
  })

  /**
   * Used to join chat room when friend is clicked
   */
  socket.on('join', (room) => {
    console.log('Joining room: ' + room)
    socket.join(room);
    console.log(socket.rooms);
  })

  /**
   * Used to leave chat room when another friend is clicked
   */
  socket.on('leave', (room) => {
    console.log('Leaving room: ' + room)
    socket.leave(room);
    console.log(socket.rooms);
  })

  /**
   * Retrieves friend list for the requesting client when client is first launched
   */
  socket.on('friends', async (user) => {
    console.log('fetching friends of: ' + user);
    const result = await getFriends(user);
    IO.to(socket.id).emit('friends', result);
  })

  /**
   * Queries db for chatID between the two users
   */
  socket.on('chat', async (users) => {
    console.log(users);
    console.log("Joining Chat with " + users.User2);
    const result = await getChatRoom(users);
    console.log(result)
    IO.to(socket.id).emit('chat', result);
  })

  /**
   * creates chatID between two users if one does not exist in db
   */
  socket.on('createChat', async (users) => {
    console.log("Creating chat room with" + users.User2);
    const result = await createChat(users);
    IO.to(socket.id).emit('chatCreated', result);
    })

  /**
   * retrieves chat history between two users
   */
  socket.on('fetchchat', async (data) => {
    console.log('fetching chat from chatID: ' + data.chatID);
    const result = await fetchChat(parseInt(data.chatID, 10));
    console.log(result);
    IO.to(socket.id).emit('fetchchat', result);
  })

  /**
   * checks db for userID and adds them as a friend if exist in db
   */
  socket.on('addfriend', async (data) => {
    const result = await addFriend(data.friendID, data.userID);
    const response = {
      result: result,
      friendID: data.friendID
    };
    IO.to(socket.id).emit('addfriends', response);
  })

  socket.on('servers', async (user) => {
    console.log('fetching servers of: ' + user);
    const result = await getServers(user); //TODO: make query
    console.log(result);
    IO.to(socket.id).emit('servers', result);
  })

  socket.on('joingroupchat', (serverID) => {
    const groupchatID = 'G' + serverID;
    console.log('joining chat: ' + groupchatID);
    socket.join(groupchatID);
  })

  socket.on('leavegroupchat', (serverID) => {
    const groupchatID = 'G' + serverID;
    console.log('leaving chat: ' + groupchatID);
    socket.leave(groupchatID);
  })

  socket.on('groupmsg', (data) => {
    const message = {
    message: data.message,
    senderUsername: username,
    sentAt: Date.now(),
    serverID: parseInt(data.serverID, 10)
    };
    console.log(message.serverID);
    storeGroupMessage(message) //TODO make query
    const room = 'G' + data.serverID.toString();
    IO.to(room).emit('groupmsg', message)
    })

    socket.on('fetchgroupchat', async (data) => {
      console.log('fetching chat from serverID: ' + data.serverID);
      const result = await fetchGroupChat(parseInt(data.serverID, 10)); //TODO make query
      console.log(result);
      IO.to(socket.id).emit('fetchgroupchat', result);
    })

  socket.on('addserver', async (data) => {
    const result = await addServer(data.serverID, data.userID); //TODO make query
    const response = {
      result: result,
      serverID: data.serverID
    };
    IO.to(socket.id).emit('addServer', response);
  })

});

httpServer.listen(3000, () => {
	console.log('Server is listening on *:3000');
});

/*
httpServer.listen(3000, '0.0.0.0', () => {
  console.log('Listening to port: ' + 3000);
});
*/
