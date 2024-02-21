import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

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
