import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

export async function getPowerPoints(UserID) {
    const [result] = await pool.query('SELECT Pptname, Ppturl from powerpoints \
    WHERE UserID = ?;', [UserID]);
    return result;
}

export async function createPowerPoint(data) {
    await pool.query('INSERT INTO powerpoints (PptName, Ppturl, UserID) \
    VALUES (?, ?, ?)', [data.title, data.url, data.userID]);
}
