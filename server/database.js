import mysql from 'mysql2'

import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database:process.env.MYSQL_DATABASE,
}).promise()

/**
 * Retrieves the message id of the most recent sent message
 * Helper funciton of store message
 * @param {*} data
 * @returns msgID
 */
async function getCurrentID(data) {
    const [id] = await pool.query('SELECT MessageID FROM messages WHERE DateReceived = ?;', [data.sentAt.toString()])
    return id
}

/**
 * Stores message into tables messages, sentmessages, and receivedmessages
 */
export async function storeMessage(data) {
    await pool.query('INSERT INTO messages (DateReceived, DataSent, MsgContent, EncryptID, ChatID) \
    VALUES (?, ?, ?, ?, ?);' , [data.sentAt, 'text', data.message, null, data.chatID]);

    const result = await getCurrentID(data);
    const msgID = result[0].MessageID;

    await pool.query('INSERT INTO sentmessages (UserID, MessageID) \
    VALUES (?, ?);' , [data.senderUsername, msgID]);

    await pool.query('INSERT INTO receivedmessages (UserID, MessageID) \
    VALUES (?, ?);' , [data.receiverUsername, msgID]);
}

/**
 * Queries database for the friends of the user
 * @param {*} userID
 * @returns
 */
export async function getFriends(userID) {
    const [rows] = await pool.query("SELECT FriendID FROM friends WHERE UserID = ?;", [userID])
    return rows
}

/**
 * Queries for the chat room ID between two users
 * @param {} users
 * @returns JSON object containing chatroomID
 */
export async function getChatRoom(users) {
    const [rows] = await pool.query("SELECT ChatID FROM privatechat WHERE (User1 = ? AND User2 = ?) \
    OR (User1 = ? AND User2 = ?);", [users.User1, users.User2, users.User2, users.User1])
    return rows
}

/**
 * Creates a new entry in database for a new chatroom between two users and returns the room number as a JSON object
 * @param {*} users
 * @returns JSON object containing the chatroomID
 */
export async function createChat(users) {
    await pool.query("INSERT INTO privatechat (User1, User2) \
    VALUES(?, ?);", [users.User1, users.User2])
    return getChatRoom(users)
}

/**
 * Queries the messages table for chat history between two users
 */
export async function fetchChat(chatID) {
    const [result] = await pool.query("SELECT messages.MsgContent as message, sentmessages.UserID as senderUsername, \
        receivedmessages.UserID as receiverUsername, messages.DateReceived as sentAt ,messages.ChatID as chatID\
        FROM ((messages \
        JOIN sentmessages ON messages.MessageID = sentmessages.MessageID)\
        JOIN receivedmessages ON messages.MessageID = receivedmessages.MessageID) \
        WHERE ChatID = ?\
        ORDER BY messages.MessageID;", [chatID]);
    return result;
}

export async function addFriend(friendID, userID) {
    //Check if friends username exists
    const [result] = await pool.query("SELECT UserID from client WHERE userID = ? OR userID = ?", [userID, friendID]);
    if (result.length > 1) {
        //check if they are already friends
        const [result2] = await pool.query("SELECT * FROM friends WHERE UserID = ? AND FriendID = ?;", [userID, friendID]);
        if (result2.length > 0){
            return false;
        }
        await pool.query("INSERT INTO friends VALUES (?, ?);", [userID, friendID]);
        await pool.query("INSERT INTO friends VALUES (?, ?);", [friendID, userID]);
        return true;
    }
    else {
        return false;
    }
}

export async function getServers(userID) {
    const [rows] = await pool.query("SELECT servertable.ServerID, servertable.ServerName \
    FROM partof \
    JOIN servertable ON partof.ServerID = servertable.ServerID \
    WHERE UserID = ?;", [userID])
    return rows
}

async function getCurrentGroupMsgID(data) {
    const [id] = await pool.query('SELECT GroupMsgID FROM groupmsgs WHERE DateReceived = ?;', [data.sentAt.toString()])
    return id
}

export async function storeGroupMessage(data) {
    await pool.query('INSERT INTO groupmsgs (DateReceived, DataSent, MsgContent, EncryptID, ServerID) \
    VALUES (?, ?, ?, ?, ?);' , [data.sentAt, 'text', data.message, null, data.serverID]);

    const result = await getCurrentGroupMsgID(data);
    const msgID = result[0].GroupMsgID;

    await pool.query('INSERT INTO groupmsgsender (UserID, GroupMsgID) \
    VALUES (?, ?);' , [data.senderUsername, msgID]);
}

export async function fetchGroupChat(serverID) {
    const [result] = await pool.query("SELECT groupmsgs.MsgContent as message, groupmsgsender.UserID as senderUsername, \
        groupmsgs.DateReceived as sentAt , groupmsgs.ServerID as serverID\
        FROM groupmsgs \
        JOIN groupmsgsender ON groupmsgs.GroupMsgID = groupmsgsender.GroupMsgID \
        WHERE ServerID = ?\
        ORDER BY groupmsgs.GroupMsgID;", [serverID]);
    return result;
}

export async function createServer(serverName, creationDate, owner) {
    const [result] = await pool.query("SELECT * from servertable WHERE owner = ? AND serverName = ?", [owner, serverName]);
    if (result.length > 0) {
        return false;
    }
    await pool.query("INSERT INTO servertable (ServerName, CreationDate, Owner) VALUES (?, ?, ?);", [serverName, creationDate, owner]);
    const ID = await getCreatedServerID(creationDate, owner);
    const serverID = ID[0].serverid;
    await pool.query("INSERT INTO partof VALUES (?, ?);", [owner, serverID]);
    return true;
}

async function getCreatedServerID(creationDate, owner) {
    const [id] = await pool.query('SELECT serverid FROM servertable WHERE CreationDate = ? AND Owner = ?;', [creationDate, owner]);
    return id
}

export async function getServerID(serverName, owner) {
    const [id] = await pool.query('SELECT serverid FROM servertable WHERE ServerName = ? AND Owner = ?;', [serverName, owner]);
    return id
}

export async function getServerMembers(serverID) {
    const [members] = await pool.query('SELECT UserID FROM partof WHERE ServerID = ?', [serverID]);
    return members;
}
