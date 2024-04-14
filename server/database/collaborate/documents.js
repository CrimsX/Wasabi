
import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()


const pool = mysql.createConnection(process.env.DATABASE_URL).promise();


export async function updateDocumentTitle(documentId, newTitle) {
  console.log('updateTitleCalled');
  const query = 'UPDATE document SET DocumentTitle = ? WHERE DocumentID = ?';
  const [result] = await pool.query(query, [newTitle, documentId]);
  return result;
}

export async function createNewDocument(username) {
  const query = 'INSERT INTO document (UserID, DocumentTitle) VALUES (?, ?)';
  const [result] = await pool.query(query, [username, 'Untitled Document']);
  // Get the last inserted ID
  const documentId = result.insertId;
  const documentTitle = result.DocumentTitle;
  const Content = result.Content;

  return { documentId, documentTitle, Content};
}

export async function saveDocumentContent(documentId, content) {
 // console.log('func 3 called')
  const contentString = JSON.stringify(content); // Ensure content is a string
  const query = 'UPDATE document SET Content = ? WHERE DocumentID = ?';
  const [result] = await pool.query(query, [contentString, documentId]);
  return result;
}



export async function shareDocument(data) {
    const [check] = await pool.query('SELECT * FROM document \
    WHERE DocumentID = ? AND UserID = ?', [data.documentId, data.friend]);
    console.log(check.length===0);
    if (check.length === 0) {
        const contentString = JSON.stringify(data.content);
        await pool.query('INSERT INTO document (DocumentID, UserID, DocumentTitle, Content) VALUES (?, ?, ?, ?)',
        [data.documentId, data.friend, data.documentTitle, contentString]);
    }
}


export async function shareDocumentGroup(data) {
    console.log(data)
    const [members] = await pool.query('SELECT UserID from partof WHERE \
    ServerID = ? and UserID != ?', [parseInt(data.group.slice(1)), data.user]);
    for (const username of members) {
        shareDocument({
            friend: username.UserID,
            documentId: data.documentId,
            documentTitle: data.documentTitle,
            content: data.content
        })
    }
}


export async function fetchDocuments(userID) {
  try {
    const [rows] = await pool.query("SELECT DocumentID, DocumentTitle, Content FROM document WHERE UserID = ?", [userID]);
    console.log("Retrieved documents:", rows);
    console.log(userID);

    return { success: true, documents: rows }; // Changed 'events' to 'documents'
  } catch (error) {
    console.error("Error fetching documents:", error);
    throw new Error('Failed to fetch documents');
  }
}
