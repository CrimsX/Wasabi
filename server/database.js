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
    const [rows] = await pool.query("SELECT * FROM client WHERE userid = ?", [id])
    return rows[0]
}

const result = await getQuery('userid')
console.log(result)
