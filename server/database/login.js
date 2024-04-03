import mysql from 'mysql2'
import dotenv from 'dotenv'
import bcrypt from 'bcrypt'

dotenv.config()

//const pool = mysql.createConnection(process.env.DATABASE_URL).promise();
const pool = mysql.createPool(process.env.DATABASE_URL).promise();

export async function socketLogin(socket, IO) {
  socket.on('login', async (data) => {
    console.log('Attempting login for:', data.userID);
    const result = await logIn(data);
    IO.to(socket.id).emit('loginResponse', result);
  });

  socket.on('createaccount', async (data) => {
    const result = await createAccount(data);
    socket.emit('createaccountResponse', {success: result.success, message: result.message}); 
  });
}

export async function logIn(data) {
    try {
        const { userID, password } = data;

        // Fetch the password for the given userID
        const [rows] = await pool.query('SELECT Pass FROM client WHERE UserID = ?', [userID]);
        //console.log(rows[0]["Pass"])
        //console.log(password);
        //console.log(bcrypt.compareSync(password, rows[0]["Pass"]))
        if (bcrypt.compareSync(password, rows[0]["Pass"])) {
        //if (password === rows[0]["Pass"]) {
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
        const { userID, displayName, password } = data;

        const salt = bcrypt.genSaltSync(10);
        const hash = bcrypt.hashSync(password, salt);

        // inserts userID FirstName, LastNAme, and password.
        const [check] = await pool.query('SELECT COUNT(UserID) FROM client WHERE UserID = ?', [userID]);
        //console.log(check[0]['COUNT(UserID)']);

        if (check[0]['COUNT(UserID)'] > 0) {
            return { success: false, message: "Username already exists." };
        } else {
          const [result] = await pool.query("INSERT INTO client (UserID,  displayName, Pass) VALUES (?, ?, ?)", [userID, displayName, hash]);
          return { success: true, message: "Account created successfully.", userID: userID };
        }
    } catch (error) {
        console.error("Error creating account:", error.message);
        return { success: false, message: "Failed to create account.", error: error.message };
    }
}
