import mysql from 'mysql2'

import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database:process.env.MYSQL_DATABASE,
}).promise()


export async function getQuery(id) {
    const [rows] = await pool.query("SELECT * FROM client WHERE Firstname = ?;", [id])
    return rows[0]
}

async function getCurrentID(data) {
    const [id] = await pool.query('SELECT MessageID FROM messages WHERE DateReceived = ?;', [data.sentAt.toString()])
    return id
}

export async function storeMessage(data) {
    await pool.query('INSERT INTO messages (DateReceived, DataSent, MsgContent, EncryptID) \
    VALUES (?, ?, ?, ?);' , [data.sentAt.toString(), 'text', data.message, null]);

    const result = await getCurrentID(data);
    const msgID = result[0].MessageID;

    await pool.query('INSERT INTO sentmessages (UserID, MessageID) \
    VALUES (?, ?);' , [data.senderUsername, msgID]);

    await pool.query('INSERT INTO receivedmessages (UserID, MessageID) \
    VALUES (?, ?);' , [data.receiverUsername, msgID]);
}

export async function getFriends(userID) {
    const [rows] = await pool.query("SELECT FriendID FROM friends WHERE UserID = ?;", [userID])
    return rows
}

export async function getChatRoom(users) {
    const [rows] = await pool.query("SELECT ChatID FROM privatechat WHERE (User1 = ? AND User2 = ?) \
    OR (User1 = ? AND User2 = ?);", [users.User1, users.User2, users.User2, users.User1])
    return rows
}

export async function createChat(users) {
    await pool.query("INSERT INTO privatechat (User1, User2) \
    VALUES(?, ?);", [users.User1, users.User2])
    return getChatRoom(users)
}
