import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()

const pool = mysql.createConnection(process.env.DATABASE_URL).promise();

export async function logIn(data) {
    try {
        const { userID, password } = data;
        // Fetch the password for the given userID
        const [rows] = await pool.query('SELECT Pass FROM client WHERE UserID = ? AND Pass = ?', [userID, password]);
        if (rows.length > 0) {
            // If a row is found, the password matches
            return { success: true, message: "Login successful" };
        } else {
            // No row found means no match for the userID/password combination
            return { success: false, message: "Incorrect username or password" };
        }
    } catch (error) {
        console.error("Login error:", error);
        return { success: false, message: "Login failed", error: error.message };
    }
}

// for create account to insert the username and password
export async function createAccount(data) {
    try {
        const { userID, Firstname, Lastname, password } = data;

        // will implement hashing for password next time

        // inserts userID FirstName, LastNAme, and password.
        const [result] = await pool.query("INSERT INTO client (UserID,  Firstname, Lastname, Pass) VALUES (?, ?, ?, ?)", [userID, Firstname, Lastname, password]);
        return { success: true, message: "Account created successfully.", userID: userID };
    } catch (error) {
        console.error("Error creating account:", error.message);
        return { success: false, message: "Failed to create account.", error: error.message };
    }
}
