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
        await pool.query("INSERT INTO events (eventNAME, eventTIME, UserID) VALUES (?, ?, ?)", [eventName, eventTime, userID]);
        const [rows] = await pool.query("SELECT eventNAME, eventTIME FROM events WHERE eventsID = LAST_INSERT_ID()");

        const newEvent = rows[0];
        console.log('Event created successfully:', newEvent);


        return { success: true, event: newEvent }; // Return the new event details
    } catch (error) {
        console.error("Error creating event:", error.message);
        return { success: false, message: "Failed to create event.", error: error.message };
    }
}



export async function getEvents(userID) {
    try {
        const [rows] = await pool.query("SELECT eventName, eventTime FROM events WHERE UserID = ?", [userID]);
        console.log("Retrieved events:", rows);
        console.log(userID);

        return { success: true, events: rows };
    } catch (error) {
        console.error("Error fetching events:", error);
        throw new Error('Failed to fetch events');
    }
}





export async function shareEvent(data) {
    // Check for necessary data
    console.log("Received data:", data);
    if (!data.eventname || !data.userID || !data.eventTIME || !data.user) {
        console.error("Missing data for shareEvent");
        throw new Error("Missing data for shareEvent"); // Throwing an error for missing data
    }

    try {
        // Step 1: Check if the event already exists for the target user (data.user)
        const [check] = await pool.query('SELECT * FROM events WHERE eventNAME = ? AND UserID = ?', [data.eventname, data.user]);
        if (check.length === 0) {
            // Step 2: Since the event doesn't exist for the target user, fetch it for the source user (data.userID)
            const rows = await pool.query('SELECT * FROM events WHERE eventName = ? AND UserID = ?', [data.eventname, data.userID]);
            console.log("this is rows:");
            console.log(rows);

            if (rows.length > 0) {
                const row = rows[0][0]; // Access the first element of the outer array, then the first element of the inner array
                console.log([row.eventsID, row.eventNAME, row.eventTIME, row.UserID]);
                // Step 3: Insert the fetched event for the target user (data.user)
                await pool.query('INSERT INTO events (eventsID, eventname, eventtime, userID) VALUES (?, ?, ?, ?)', [row.eventsID, data.eventname, row.eventTIME, data.user]);

                console.log("Event shared successfully");
            } else {
                throw new Error("Event not found for the source user");
            }
        } else {
            console.log("Event already exists for the target user");
        }
    } catch (error) {
        console.error("Error in shareEvent:", error);
        throw error; // Rethrow the error to be handled by the caller
    }
}






export async function shareEventGroup(data) {
    const [members] = await pool.query('SELECT UserID from partof WHERE \
    ServerID = ? and UserID != ?', [parseInt(data.group.slice(1)), data.user]);
    for (const username of members) {
        shareEvent({
            user: username.UserID,
            'eventsid': data.eventid,
            'eventname': data.eventname,
        })
    }
}



export async function insertTaskIntoDatabase(taskName, userID) {
    try {
        const [result] = await pool.query("INSERT INTO tasks (taskName, taskStatus, UserID) VALUES (?, ?, ?)", [taskName, 0, userID]);
        const [data] =  await pool.query("SELECT taskID, taskName, taskStatus FROM tasks WHERE taskID = ?", [result.insertId]);
        return data
    } catch (error) {
        console.error("Error creating task:", error.message);
        throw error;
    }
}

// Function to update task status by ID from 0 to 1
export async function updateTaskStatus(taskID) {
    try {
        await pool.query('UPDATE tasks SET taskStatus = 1 WHERE taskID = ?;', [taskID]);
        return { success: true, ID:taskID };
    } catch (error) {
        console.error("Error updating task status:", error);
        return { success: false, message: "Failed to update task status", error: error.message };
    }
}

export async function undoTaskStatus(taskID) {
  try {
    await pool.query('UPDATE tasks SET taskStatus = 0 WHERE taskID = ?;', [taskID]);
    return { success: true, ID: taskID };
  } catch (error) {
    console.error("Error undoing task status:", error);
    return { success: false, message: "Failed to undo task status", error: error.message };
  }
}

// Function to delete a task by ID:

export async function deleteTask(taskID) {
  try {
    //database deletion logic
    await pool.query('DELETE FROM tasks WHERE taskID = ?', [taskID]);

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

export async function shareToDo(data) {
    const [check] = await pool.query('SELECT * FROM tasks \
    WHERE taskID = ? AND UserID = ?', [data.taskid, data.userid]);
    console.log(check.length===0);
    if (check.length === 0) {
        await pool.query('INSERT INTO tasks (taskID, taskName, taskStatus, UserID) \
    VALUES (?, ?, ?, ?)', [data.taskid, data.taskname, 0, data.user]);
    }
}

export async function shareToDoGroup(data) {
    const [members] = await pool.query('SELECT UserID from partof WHERE \
    ServerID = ? and UserID != ?', [parseInt(data.group.slice(1)), data.user]);
    for (const username of members) {
        shareToDo({
            user: username.UserID,
            'taskid': data.taskid,
            'taskname': data.taskname
        })
    }
}
