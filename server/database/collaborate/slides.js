import mysql from 'mysql2'
import dotenv from 'dotenv'

import {Server} from 'socket.io'

dotenv.config()

const pool = mysql.createPool(process.env.DATABASE_URL).promise();

// Wasabi slides
export async function socketWasabiSlides(socket, IO) {
    socket.on('getSlides', async (username) => {
      const ppts = await getAllSlides(username);
      console.log(ppts);
      IO.to(socket.id).emit('getSlides', ppts);
    })

    socket.on('getSlide', async (data) => {
    const result = await getSlide(data);
    IO.to(socket.id).emit('getSlide', result);
    })

    socket.on('createSlide', async (data) => {
      const result = await newSlide(data);
      //IO.to(socket.id).emit('createSlide', result)
    })

    socket.on('deleteSlide', async (data) => {
      await deleteSlide(data);
    }) 

    socket.on('shareSlideFriend', async (data) => {
      await shareSlide(data);
    })

    socket.on('shareSlideServer', async (data) => {
      await shareSlideServer(data);
    })

    socket.on('getTotalSlides', async (data) => {
      const result = await totalSlides(data);
      IO.to(socket.id).emit('getTotalSlides', result);
    })

    socket.on('exportSlides', async (data) => {
      const result = await exportSlides(data);
      IO.to(socket.id).emit('exportSlides', result);
    })
}

export async function newSlide(data) {
    const [check] = await pool.query('SELECT * FROM WasabiSlides \
    WHERE Name = ? AND userID = ? AND SlideNum = ?', [data.title, data.userID, data.num]);
    if (check.length !== 0) {
      await pool.query('UPDATE WasabiSlides \
      SET SlideHeader = ?, SlideContent = ? \
      WHERE SlideNum = ? AND Name = ? AND userID = ?', [data.header, data.content, data.num, data.title, data.userID]);
      const [result] = await pool.query('SELECT * FROM WasabiSlides \
      WHERE userID = ? AND Name = ?', [data.userID, data.title]);
      return result;
    } else {
      await pool.query('INSERT INTO WasabiSlides (Name, userID, SlideNum, SlideHeader, SlideContent) \
      VALUES (?, ?, ?, ?, ?)', [data.title, data.userID, data.num, data.header, data.content]);
      const [result] = await pool.query('SELECT * FROM WasabiSlides \
      WHERE userID = ? AND Name = ?', [data.userID, data.title]);
      return result;
    }
}

export async function getAllSlides(userID) {
    const [result] = await pool.query('SELECT Name from WasabiSlides \
    WHERE userID = ? AND SlideNum = 1;', [userID]);
    return result;
}

export async function getSlide(data) {
    const [result] = await pool.query('SELECT * from WasabiSlides \
    WHERE userID = ? AND Name = ? AND SlideNum = ?', [data.username, data.name, data.slideNum]);
    return result; 
}

export async function deleteSlide(data) {
    await pool.query('DELETE FROM WasabiSlides WHERE userID = ? AND Name = ?', [data.user, data.name]);
}

export async function shareSlide(data) {
  const [result] = await pool.query(
  'INSERT INTO WasabiSlides (userID, Name, SlideNum, SlideHeader, SlideContent) \
  SELECT ?, Name, SlideNum, SlideHeader, SlideContent \
  FROM WasabiSlides \
  WHERE userID = ? AND Name = ?',
  [data.friend, data.user, data.name]
  );
  /*
    const [check] = await pool.query('SELECT * FROM WasabiSlides \
    WHERE ID = ? AND userID = ?', [data.Ppt.ID, data.user]);
    console.log(check.length===0);
    if (check.length === 0) {
        await pool.query('INSERT INTO WasabiSlides (ID, userID, Name, SlideNum, SlideHeader, SlideContent) \
    VALUES (?, ?, ?, ?)', [data.Ppt.PptID, data.user, data.Ppt.PptName, data.Ppt.Num, data.Ppt.Header, data.Ppt.Content]);
    */
    //}
}

export async function shareSlideServer(data) {
  const [members] = await pool.query('SELECT UserID from partof WHERE \
    ServerID = ? and UserID != ?', [parseInt(data.group.slice(1)), data.Ppt.UserID]);
    for (const username of members) {
        shareSlide({
            friend: data.friend,
            user: username.UserID,
            name: data.name
        })
    }
}

export async function totalSlides(data) {
  const [result] = await pool.query(
    'SELECT COUNT(*) \
    FROM WasabiSlides \
    WHERE userID = ? AND Name = ?',
    [data.username, data.name]);
  return result;
}

export async function exportSlides(data) {
  const [result] = await pool.query(
    'SELECT * \
    FROM WasabiSlides \
    WHERE userID = ? AND Name = ? \
    ORDER BY SlideNum',
    [data.username, data.name]);
  return result;
}

// Web slides
//
//
export async function socketWebSlides(socket, IO) {
  socket.on('getpowerpoints', async (username) => {
      const ppts = await getPowerPoints(username);
      console.log(ppts);
      IO.to(socket.id).emit('getpowerpoints', ppts);
    })

    socket.on('createppt', async (data) => {
      const result = await createPowerPoint(data);
      IO.to(socket.id).emit('createppt', result)
    })

    socket.on('deleteppt', async (data) => {
      await deletePowerPoint(data);
    })

    socket.on('sharepptfriend', async (data) => {
      await sharePPT(data);
    })

    socket.on('sharepptgroup', async (data) => {
      await sharePPTGroup(data);
    })
}

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
