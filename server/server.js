//import express from 'express'
//import http from 'http'
import {Server} from 'socket.io'

import {
  createEvent,
  getEvents,
  insertTaskIntoDatabase,
  updateTaskStatus,
  undoTaskStatus,
  deleteTask,
  getAllTasks,
  shareToDo,
  shareToDoGroup,
  getPowerPoints,
  createPowerPoint,
  deletePowerPoint,
  sharePPT,
  sharePPTGroup
} from './database/collaborate.js'

import {
  logIn,
  createAccount,
} from './database/login.js'

import {
  getFriends,
  createChat,
  getChatRoom,
  addFriend,
} from './database/individual.js'

import {
  getServers,
  storeGroupMessage,
  fetchGroupChat,
  createServer,
  getServerID,
  getServerMembers,
} from './database/group.js'

import {
  storeMessage,
  fetchChat,
} from './database/messaging.js'


let port = process.env.PORT || 3000;

//const app = express();
//const httpServer = http.createServer(app);
//const IO = new Server(httpServer);
//
const messages = []

let callerId;
let onlineUsers = {};

let IO = new (Server) (port, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

IO.use((socket, next) => {
  if (socket.handshake.query) {
    callerId = socket.handshake.query.callerId;
    socket.user = callerId;
    next();
  }
});

//console.log('Server is listening on *:3000');

IO.on("connection", (socket) => {
  console.log(socket.user, "Connected");
  socket.join(socket.user);

  const username = socket.handshake.query.username
  console.log("User connected:", username)

  onlineUsers[username] = callerId;
  //console.log(Object.keys(onlineUsers));

  const active = new Set();
  active.add(username);

  //IO.emit("Active connections:", Array.from(active));

  /************************************************************************************
   * Account Creation
   ************************************************************************************/


    socket.on('createEvent', async (data) => {
        const result = await createEvent(data);
        console.log('test');
    });



    socket.on('getEvents', async (userID) => {
        const result = await getEvents(userID);
        IO.to(socket.id).emit('eventsResponse', result.events);
    });



     socket.on('createTask', async (data) => {
         console.log('Received task data:', data);
         try {
           const { taskName, userID } = data;
           // Call the function from database.js to insert task into the database
           const result = await insertTaskIntoDatabase(taskName, userID);
           console.log('Task created successfully:', result);
           // Emit a confirmation event back to the client
           socket.emit('taskCreated', { success: true, result });
         } catch (error) {
           console.error('Error creating task:', error);
           // Emit an error event back to the client if task creation fails
           socket.emit('taskCreationFailed', { success: false, error: error.message });
         }
       });


     socket.on('updateTaskStatus', async (taskId) => {
        try {
          // Call the updateTaskStatus function from the database module
          const result = await updateTaskStatus(taskId);
          // Emit a response back to the client indicating whether the task status update was successful
          IO.to(socket.id).emit('taskStatusUpdated', result);
        } catch (error) {
          console.error('Error updating task status:', error);
          // Emit an error response back to the client if the task status update fails
          IO.to(socket.id).emit('taskStatusUpdateFailed', { success: false, error: error.message });
        }

     });

     socket.on('undoTaskStatus', async (taskId) => {
       try {
         // Call the function to update task status to 0 (opposite of 1) in the database
         const result = await undoTaskStatus(taskId);
         // Emit a response back to the client indicating whether the task status update was successful
         IO.to(socket.id).emit('taskStatusUndone', result);
       } catch (error) {
         console.error('Error undoing task status:', error);
         // Emit an error response back to the client if the task status update fails
         IO.to(socket.id).emit('taskStatusUndoFailed', { success: false, error: error.message });
       }
     });

       socket.on('deleteTask', async (taskID) => {
         try {
           // Call the deleteTask function from the database module
           const result = await deleteTask(taskID);
           // Emit a response back to the client indicating whether the task deletion was successful
           IO.to(socket.id).emit('taskDeleted', result);
         } catch (error) {
           console.error('Error deleting task:', error);
           // Emit an error response back to the client if the task deletion fails
           IO.to(socket.id).emit('taskDeletionFailed', { success: false, error: error.message });
         }
       });

     socket.on('getTasks', async (userID) => {
       try {
         const tasks = await getAllTasks(userID);
         socket.emit('tasks', tasks);
       } catch (error) {
         // Handle error
         console.error('Error:', error.message);
         socket.emit('error', { message: 'Failed to fetch tasks' });
       }
     });

     socket.on('sharetodofriend', async (data) => {
      await shareToDo(data);
    })

    socket.on('sharetodogroup', async (data) => {
      await shareToDoGroup(data);
    })


  // Kipp
    socket.on('createaccount', async (data) => {
       const result = await createAccount(data);
          if (result.success) {
              // Inform the client of the successful account creation
              socket.emit('accountCreated', result);
          } else {
              // Inform the client that account creation failed
              socket.emit('accountCreationFailed', result);
          }
    });

    socket.on('login', async (data) => {
      console.log('Attempting login for:', data.userID);
      const result = await logIn(data);
      IO.to(socket.id).emit('loginResponse', result);
    });


  /************************************************************************************
   * Voice Calls
   ************************************************************************************/
// Kipp

  socket.on("makeCall", (data) => {
    let calleeId = data.calleeId;
    let sdpOffer = data.sdpOffer;
    let showVid = data.showVid;

    socket.to(calleeId).emit("newCall", {
      callerId: socket.user,
      sdpOffer: sdpOffer,
      showVid: showVid,
    });
    //console.log(sdpOffer);
    //console.log("Call sent");
    //console.log(showVid);
  });

  socket.on("answerCall", (data) => {
    let callerId = data.callerId;
    let sdpAnswer = data.sdpAnswer;
    let showVid = data.showVid;

    socket.to(callerId).emit("callAnswered", {
      callee: socket.user,
      sdpAnswer: sdpAnswer,
      showVid: showVid,
    });
  });

  socket.on("IceCandidate", (data) => {
    let calleeId = data.calleeId;
    let iceCandidate = data.iceCandidate;

    socket.to(calleeId).emit("IceCandidate", {
      sender: socket.user,
      iceCandidate: iceCandidate,
    });
  });

  socket.on('disconnect', () => {
    console.log("User disconnected:", username);
    delete onlineUsers[username];

    active.delete(username);
    IO.emit("Active connections:", Array.from(active));
  });

  /************************************************************************************
   * Direct Messaging
   ************************************************************************************/

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

  /************************************************************************************
   * Group Messaging
   ************************************************************************************/

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
    const result = await createServer(data.serverName, Date.now(), data.owner);
    const ID = await getServerID(data.serverName, data.owner);
    const response = {
      result: result,
      serverID: ID[0].serverid.toString(),
      serverName: data.serverName
    };
    IO.to(socket.id).emit('addServer', response);
  })

  socket.on('getservermembers', async (serverID) => {
    const result = await getServerMembers((parseInt(serverID, 10)));
    console.log(result);
    IO.to(socket.id).emit('getservermembers', result);
  })

  socket.on("requestVoIPID", (data) => {
    var keys = Object.keys(onlineUsers);
    keys.forEach(key => {
      if (key == data) {
        IO.to(socket.id).emit('r_VoIPID', onlineUsers[key]);
      }
    })
  });

  /************************************************************************************
   * Powerpoint
   ************************************************************************************/
    socket.on('getpowerpoints', async (username) => {
      const ppts = await getPowerPoints(username);
      console.log(ppts);
      IO.to(socket.id).emit('getpowerpoints', ppts);
    })

    socket.on('createppt', async (data) => {
      const result = await createPowerPoint(data);
      IO.to(socket.id).emit('createppt', result)
    })

    socket.on('deleteppt', async (data) => {
      await deletePowerPoint(data);
    })

    socket.on('buildfriendscollab', async (user) => {
      const result = await getFriends(user);
      IO.to(socket.id).emit('buildfriendscollab', result);
    })

    socket.on('buildgroupscollab', async (user) => {
      const result = await getServers(user); //TODO: make query
      IO.to(socket.id).emit('buildgroupscollab', result);
    })

    socket.on('sharepptfriend', async (data) => {
      await sharePPT(data);
    })

    socket.on('sharepptgroup', async (data) => {
      await sharePPTGroup(data);
    })
});
