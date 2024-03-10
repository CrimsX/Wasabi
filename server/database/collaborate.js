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

export async function createEvent(data) {
    try {
        console.log('Attempting to create event with data:', data);
        const { eventName, eventTime, userID } = data;
        const [result] = await pool.query("INSERT INTO events (eventNAME, eventTIME, UserID) VALUES (?, ?, ?)", [eventName, eventTime, userID]);
        console.log('Event created successfully:', result);
        return { success: true, message: "Event created successfully.", eventID: result.insertId };
    } catch (error) {
        console.error("Error creating event:", error.message);
        return { success: false, message: "Failed to create event.", error: error.message };
    }
}




export async function getEvents(userID) {
    try {
        const [rows] = await pool.query("SELECT * FROM events WHERE UserID = ?", [userID]);
        return { success: true, events: rows };
    } catch (error) {
        console.error("Error fetching events:", error.message);
        return { success: false, message: "Failed to fetch events.", error: error.message };
    }
}


export async function insertTaskIntoDatabase(taskName, userID) {
    try {
        const [result] = await pool.query("INSERT INTO tasks (taskName, taskStatus, UserID) VALUES (?, ?, ?)", [taskName, 0, userID]);
        return { success: true, taskID: result.insertId };
    } catch (error) {
        console.error("Error creating task:", error.message);
        throw error;
    }
}

// Function to update task status by ID from 0 to 1
export async function updateTaskStatus(taskID) {
    try {
        await pool.query('UPDATE tasks SET taskStatus = 1 WHERE tasksID = ?;', [taskID]);
        return { success: true, message: "Task status updated successfully" };
    } catch (error) {
        console.error("Error updating task status:", error);
        return { success: false, message: "Failed to update task status", error: error.message };
    }
}

export async function undoTaskStatus(taskID) {
  try {
    await pool.query('UPDATE tasks SET taskStatus = 0 WHERE tasksID = ?;', [taskID]);
    return { success: true, message: "Task status undone successfully" };
  } catch (error) {
    console.error("Error undoing task status:", error);
    return { success: false, message: "Failed to undo task status", error: error.message };
  }
}

// Function to delete a task by ID:

export async function deleteTask(taskID) {
  try {
    //database deletion logic
    await pool.query('DELETE FROM tasks WHERE id = ?', [taskID]);

    return { success: true, message: "Task deleted successfully" };
  } catch (error) {
    console.error("Error deleting task:", error);
    return { success: false, message: "Failed to delete task", error: error.message };
  }
}

export async function getAllTasks(userID) {
  try {
    // Query the database to get all tasks for the user
    const [rows] = await pool.query('SELECT TaskID, TaskName, TaskStatus FROM tasks WHERE UserID = ?;', [userID]);

    const unfinishedTasks = rows.filter(task => task.TaskStatus === 0);
    const finishedTasks = rows.filter(task => task.TaskStatus === 1);

    const combinedTasks = [...unfinishedTasks, ...finishedTasks];

    return combinedTasks;
  } catch (error) {
    // Handle errors
    console.error('Error fetching tasks:', error);
    throw new Error('Failed to fetch tasks');
  }
}
