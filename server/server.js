//import express from 'express'
//import http from 'http'
import {Server} from 'socket.io'

import {
  socketWasabiSlides,
  socketWebSlides,
} from './database/collaborate/slides.js'

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
  shareEventGroup,
  shareEvent,
} from './database/collaborate.js'

import {
  socketLogin,
} from './database/login.js'

import {
    updateDocumentTitle,
    createNewDocument,
    saveDocumentContent,
    shareDocument,
    shareDocumentGroup,
    fetchDocuments,
} from './database/collaborate/documents.js'

import {
  getFriends,
  createChat,
  getChatRoom,
  addFriend,
  removeFriend
} from './database/individual.js'

import {
  getServers,
  storeGroupMessage,
  fetchGroupChat,
  createServer,
  getServerID,
  getServerMembers,
  inviteToServer,
  leaveServer
} from './database/group.js'

import {
  storeMessage,
  fetchChat,
} from './database/messaging.js'

import {
  socketLiveKit,
} from './livekit/room.js'

let port = process.env.PORT || 8080;

//const app = express();
//const httpServer = http.createServer(app);
//const IO = new Server(httpServer);
//
//const messages = []

let callerId;
let onlineUsers = {};
let userRoom = {};

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

  let username = socket.handshake.query.username
  console.log("User connected:", username)

  onlineUsers[username] = callerId;
  const firstRoom = Array.from(socket.rooms)[0];
  userRoom[username]= firstRoom;
  const active = new Set();
  active.add(username);

  //IO.emit("Active connections:", Array.from(active));

  /************************************************************************************
  * Account Creation
  ************************************************************************************/
  socket.on('getUsername', async (data) => {
    username = data.username;
  });

  socketLogin(socket, IO);

  console.log('server');
  console.log(username, userRoom[username])

  socketLiveKit(socket, IO, username);
  
  socket.on("joinRoom", (data) => {
    let calleeId = data.calleeId;
    socket.to(calleeId).emit("joinRoom", {
      roomOffer: data.userName,
      //callerId: socket.user,
      //sdpOffer: sdpOffer,
      //showVid: showVid,
    });
    //console.log(sdpOffer);
    //console.log("Call sent");
    //console.log(showVid);
  });

  /************************************************************************************
  * Document :
  ************************************************************************************/

  socket.on('updateDocumentTitle', async (data) => {
      const { documentId, newTitle } = data;
      try {
        console.log('updateDocumentTitle function is being called...');
        await updateDocumentTitle(documentId, newTitle);
        socket.emit('documentTitleUpdated', { success: true, documentId, newTitle });
      } catch (error) {
        console.error('Error updating document title:', error);
        socket.emit('documentTitleUpdateFailed', { success: false, error: error.message });
      }
    });

  socket.on('saveDocumentContent', async (data) => {
    const { documentId, content } = data;
    //console.log('Socket save Doc')
    try {
      // Call a function to save the document content to the database
      await saveDocumentContent(documentId, content);
      socket.emit('documentContentSaved', { success: true });
      //console.log('Socket save Doc 2')
    } catch (error) {
      console.error('Error saving document content:', error);
      socket.emit('documentContentSaveFailed', { success: false, error: error.message });
    }
  });

  socket.on('createNewDocument', async (data) => {
    const { username } = data;
    try {
      // Insert a new document into the database
      const { documentId, documentTitle, Content } = await createNewDocument(username);
      // Emit the newly created document ID, title, and content back to the client
      socket.emit('documentCreated', { documentId, documentTitle, Content });
    } catch (error) {
      console.error('Error creating new document:', error);
      socket.emit('documentCreationFailed', { error: error.message });
    }
  });


  socket.on('shareDocument', async (data) => {
        await shareDocument(data);
  });

  socket.on('shareDocumentGroup', async (data) => {
         await shareDocumentGroup(data);
  });

  socket.on('fetchDocuments', async (userID) => {
    try {
      const documents = await fetchDocuments(userID);
      socket.emit('documents', documents);
    } catch (error) {
      console.error('Error:', error.message);
      socket.emit('error', { message: 'Failed to fetch documents' });
    }
  });

  // When a user connects (this works)
  socket.on('joinRoom', ({ roomId }) => {
    socket.join(roomId); // Join the room based on document ID
    console.log(`User joined the room ${roomId}`);
  });

  // When a user disconnects or leaves the document (this works)
  socket.on('leaveRoom', ({ roomId }) => {
    socket.leave(roomId); // Leave the room based on document ID
    console.log(`User left the room ${roomId}`);
  });

  // fetchDocumentContent is called , this does not update.
  // I try to broadcast to documentId since thats the room, then emit'BroadcastContent' to pass on the documentId and
  // content.

  socket.on('fetchDocumentContent', ({ documentId, content }) => {
      console.log('fetchDocumentContent called');
      console.log(documentId),
      console.log(content),
       socket.broadcast.to(documentId).emit('BroadcastContent', { documentId, content }); // this does not work i think
      console.log('Broadcast successful')
  });

  /************************************************************************************
  * Calendar :
  ************************************************************************************/


   socket.on('createEvent', async (data) => {
               const result = await createEvent(data);
               if (result.success) {
                   console.log('Emitting back newly created event data:', result.event);
                   // Emit the new event details back to the client
                   socket.emit('eventCreated', result.event);
               } else {
                   console.error('Failed to create event:', result.message);
               }
           });


            socket.on('getEvents', async (userID)=>{
               try {
                   const task = await getEvents(userID);
                   socket.emit('eventResponse', task.events);
               } catch (error) {
               console.error('Error:', error.message);
               socket.emit('error', {message: 'failed to retrieve events'})
               }
            });


            socket.on('shareEvent', async (data) => {
             await shareEvent(data);
           });

           socket.on('shareEventGroup', async (data) => {
             await shareEventGroup(data);
           });



      /************************************************************************************
       ************************************************************************************/



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

  /************************************************************************************
   * Voice Calls
   ************************************************************************************/

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
    IO.to(data.chatroom).emit('message', message)
    storeMessage(message);
    //messages.push(message);
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
    IO.to(userRoom[data.friendID]).emit('receivefriends', {result: true, friendID: data.userID});
  })

  socket.on('removefriend', async (data) => {
    await removeFriend(data.friendID, data.userID);
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
    IO.to(room).emit('groupmsg', message)
    storeGroupMessage(message) //TODO make query
    const room = 'G' + data.serverID.toString();
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
    console.log(onlineUsers);
    var keys = Object.keys(onlineUsers);
    keys.forEach(key => {
      if (key == data) {
        IO.to(socket.id).emit('r_VoIPID', onlineUsers[key]);
      }
    })
  });

  socket.on("invite", async (data) => {
    console.log(data);
    console.log(userRoom);
    await inviteToServer(data);
    IO.to(userRoom[data.friendID]).emit('invite', data);
  });

  socket.on("leaveserver", async (data) => {
    await leaveServer(data);
    IO.to(socket.id).emit('leaveserver', data);
  });

  /************************************************************************************
   * Powerpoint
   ************************************************************************************/
    // Wasabi Slides
    socketWasabiSlides(socket, IO);

    // Web Slides
    socketWebSlides(socket, IO);

    socket.on('buildfriendscollab', async (user) => {
      const result = await getFriends(user);
      IO.to(socket.id).emit('buildfriendscollab', result);
    })

    socket.on('buildgroupscollab', async (user) => {
      const result = await getServers(user); //TODO: make query
      IO.to(socket.id).emit('buildgroupscollab', result);
    })

  /************************************************************************************
   * Draw
   ************************************************************************************/
    socket.on('joinwhiteboard', () => {
      console.log("connect to di")
      socket.join('d1');
    })

    socket.on('senddrawing', (data) => {
      console.log(data)
      IO.to('d1').emit('fetchlive', (data));
    })

    socket.on('clear', (username) => {
      IO.to('d1').emit('clear', (username));
    })

    socket.on('undo', (username) => {
      IO.to('d1').emit('undo', (username));
    })

    socket.on('redo', (username) => {
      IO.to('d1').emit('redo', (username));
    })
});
