import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

export async function createPP(data) {
    await pool.query('INSERT INTO pp (ppName, userID, ppURL) \
    VALUES (?, ?, ?)', [data.title, data.userID, data.url]);
    const [result] = await pool.query('SELECT * FROM pp \
    WHERE ppurl = ?', [data.url]);
    return result;
}

export async function getPP(userID) {
    const [result] = await pool.query('SELECT * from pp \
    WHERE userID = ?;', [userID]);
    return result;
}

export async function getPPSlides(userID, ppName) {
    const [result] = await pool.query('SELECT * from pp \
    WHERE userID = ? AND ppName = ?;', [userID, ppName]);
    return result; 
}

export async function deletePP(data) {
    await pool.query('DELETE FROM pp WHERE ppID = ? AND userID = ?', [data.ppID, data.user]);
}

export async function sharePP(data) {
    const [check] = await pool.query('SELECT * FROM pp \
    WHERE ppID = ? AND userID = ?', [data.Ppt.PptID, data.user]);
    console.log(check.length===0);
    if (check.length === 0) {
        await pool.query('INSERT INTO pp (ppID, ppName, ppurl, userID) \
    VALUES (?, ?, ?, ?)', [data.Ppt.PptID, data.Ppt.PptName, data.Ppt.Ppturl, data.user]);
    }
}

