import mysql from 'mysql2'
import dotenv from 'dotenv'

dotenv.config()


const pool = mysql.createConnection(process.env.DATABASE_URL).promise();


export async function updateDocumentTitle(documentId, newTitle) {
  const query = 'UPDATE document SET DocumentTitle = ? WHERE DocumentID = ?';
  const [result] = await pool.query(query, [newTitle, documentId]);
  return result;
}

export async function createNewDocument(username) {
  const query = 'INSERT INTO document (UserID, DocumentTitle) VALUES (?, ?)';
  const [result] = await pool.query(query, [username, 'Untitled Document']);

  // Get the last inserted ID
  const documentId = result.insertId;
  const documentTitle = 'Untitled Document'

  return { documentId, documentTitle };
}

export async function saveDocumentContent(documentId, content) {
  const query = 'UPDATE document SET Content = ? WHERE DocumentID = ?';
  const [result] = await pool.query(query, [content, documentId]);
  return result;
}
