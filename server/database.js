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
