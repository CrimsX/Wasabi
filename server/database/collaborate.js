import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

export async function getPowerPoints(UserID) {
    const [result] = await pool.query('SELECT * from powerpoints \
    WHERE UserID = ?;', [UserID]);
    return result;
}

export async function createPowerPoint(data) {
    await pool.query('INSERT INTO powerpoints (PptName, Ppturl, UserID) \
    VALUES (?, ?, ?)', [data.title, data.url, data.userID]);
    const [result] = await pool.query('SELECT * FROM powerpoints \
    WHERE Ppturl = ?', [data.url]);
    return result;
}

export async function deletePowerPoint(data) {
    console.log(data.PptID)
    console.log(data.user)
    await pool.query('DELETE FROM powerpoints WHERE PptID = ? AND UserID = ?', [data.PptID, data.user]);
}

export async function sharePPT(data) {
    const [check] = await pool.query('SELECT * FROM powerpoints \
    WHERE PptID = ? AND UserID = ?', [data.Ppt.PptID, data.user]);
    console.log(check.length===0);
    if (check.length === 0) {
        await pool.query('INSERT INTO powerpoints (PptID, PptName, Ppturl, UserID) \
    VALUES (?, ?, ?, ?)', [data.Ppt.PptID, data.Ppt.PptName, data.Ppt.Ppturl, data.user]);
    }
}

export async function sharePPTGroup(data) {
    const [members] = await pool.query('SELECT UserID from partof WHERE \
    ServerID = ? and UserID != ?', [parseInt(data.group.slice(1)), data.Ppt.UserID]);
    for (const username of members) {
        sharePPT({
            user: username.UserID,
            Ppt: data.Ppt
        })
    }
}
