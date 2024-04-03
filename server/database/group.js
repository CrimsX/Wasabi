import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

async function getCurrentGroupMsgID(data) {
    const [id] = await pool.query('SELECT GroupMsgID FROM groupmsgs WHERE DateReceived = ?;', [data.sentAt.toString()])
    return id
}

async function getCreatedServerID(creationDate, owner) {
    const [id] = await pool.query('SELECT serverid FROM servertable WHERE CreationDate = ? AND Owner = ?;', [creationDate, owner]);
    return id
}

export async function getServers(userID) {
    const [rows] = await pool.query("SELECT servertable.ServerID, servertable.ServerName \
    FROM partof \
    JOIN servertable ON partof.ServerID = servertable.ServerID \
    WHERE UserID = ?;", [userID])
    return rows
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

export async function getServerID(serverName, owner) {
    const [id] = await pool.query('SELECT serverid FROM servertable WHERE ServerName = ? AND Owner = ?;', [serverName, owner]);
    return id
}

export async function getServerMembers(serverID) {
    const [members] = await pool.query('SELECT UserID FROM partof WHERE ServerID = ?', [serverID]);
    return members;
}

export async function inviteToServer(data){
    console.log(data);
    await pool.query("INSERT INTO partof VALUES (?, ?);", [data.friendID, data.serverID]);
}

export async function leaveServer(data) {
    await pool.query("DELETE FROM partof WHERE UserID = ? AND ServerID = ?",[data.username, data.serverID]);
}
