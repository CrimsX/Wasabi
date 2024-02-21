import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

/*
const old_pool = mysql.createPool({
    host: process.env.MYSQL_HOST,
    user: process.env.MYSQL_USER,
    password: process.env.MYSQL_PASSWORD,
    database:process.env.MYSQL_DATABASE,
}).promise()
*/

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

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


async function getCurrentGroupMsgID(data) {
    const [id] = await pool.query('SELECT GroupMsgID FROM groupmsgs WHERE DateReceived = ?;', [data.sentAt.toString()])
    return id
}

async function getCreatedServerID(creationDate, owner) {
    const [id] = await pool.query('SELECT serverid FROM servertable WHERE CreationDate = ? AND Owner = ?;', [creationDate, owner]);
    return id
}
