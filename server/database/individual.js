import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

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
 * Queries for the chat room ID between two users
 * @param {} users
 * @returns JSON object containing chatroomID
 */
export async function getChatRoom(users) {
    const [rows] = await pool.query("SELECT ChatID FROM privatechat WHERE (User1 = ? AND User2 = ?) \
    OR (User1 = ? AND User2 = ?);", [users.User1, users.User2, users.User2, users.User1])
    return rows
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
