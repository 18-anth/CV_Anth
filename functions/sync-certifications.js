/**
 * 🔄 Firebase Cloud Function para sincronizar certificaciones
 *
 * Despliegue:
 *   cd functions && firebase deploy --only functions:syncCertificationsScheduled
 *
 * Se ejecuta automáticamente cada hora
 */

const functions = require('firebase-functions');
const { google } = require('googleapis');
const admin = require('firebase-admin');

// Inicializar Firebase Admin (se hace automáticamente en Cloud Functions)
admin.initializeApp();

const db = admin.database();

/**
 * Extrae el nombre de la certificación del nombre del archivo
 */
function extractCertName(fileName) {
  return fileName
    .replace(/\.[^/.]+$/, '') // Elimina extensión
    .replace(/_/g, ' ') // Reemplaza _ con espacios
    .replace(/\b\w/g, (char) => char.toUpperCase()); // Capitaliza palabras
}

/**
 * Lista archivos de Google Drive usando service account
 */
async function listFilesInFolder(folderId, auth) {
  try {
    const drive = google.drive({ version: 'v3', auth });

    const response = await drive.files.list({
      q: `'${folderId}' in parents and trashed=false and mimeType!='application/vnd.google-apps.folder'`,
      spaces: 'drive',
      fields: 'files(id, name, mimeType, webViewLink, createdTime)',
      pageSize: 100,
    });

    return response.data.files || [];
  } catch (error) {
    console.error('Error al listar archivos de Drive:', error);
    throw error;
  }
}

/**
 * Cloud Function: Sincronizar certificaciones cada hora
 * Trigger: Cloud Scheduler (cada hora)
 */
exports.syncCertificationsScheduled = functions
  .region('us-central1')
  .pubsub.schedule('every 1 hours')
  .onRun(async (context) => {
    try {
      console.log('🔄 Iniciando sincronización de certificaciones...');

      // Obtener configuración desde variables de entorno
      const folderId = process.env.GOOGLE_DRIVE_FOLDER_ID;
      if (!folderId) {
        throw new Error('GOOGLE_DRIVE_FOLDER_ID no configurada');
      }

      // Crear cliente de Google Drive con service account
      const auth = new google.auth.GoogleAuth({
        scopes: ['https://www.googleapis.com/auth/drive.readonly'],
      });

      // Obtener archivos
      const files = await listFilesInFolder(folderId, auth);
      console.log(`✅ Encontrados ${files.length} archivos`);

      if (files.length === 0) {
        console.log('⚠️  No hay archivos para sincronizar');
        return { message: 'No files to sync', synced: 0 };
      }

      // Sincronizar con Firebase
      const certRef = db.ref('Certifications');
      const currentCerts = (await certRef.get()).val() || {};

      let synced = 0;
      let created = 0;
      let updated = 0;

      for (const file of files) {
        const { id: fileId, name: fileName } = file;
        const certName = extractCertName(fileName);

        // Buscar certificación existente
        let existingId = null;
        for (const [certId, certData] of Object.entries(currentCerts)) {
          if (certData.driveFileId === fileId) {
            existingId = certId;
            break;
          }
        }

        const certData = {
          name: certName,
          driveFileId: fileId,
          description: `Sincronizado automáticamente - ${new Date().toLocaleDateString()}`,
          lastSyncedAt: Date.now(),
        };

        try {
          if (existingId) {
            await certRef.child(existingId).update(certData);
            updated++;
          } else {
            const newId = certRef.push().key;
            await certRef.child(newId).set(certData);
            created++;
          }
          synced++;
        } catch (error) {
          console.error(`Error al procesar ${certName}:`, error);
        }
      }

      const result = {
        message: 'Sync completed',
        synced,
        created,
        updated,
        timestamp: new Date().toISOString(),
      };

      console.log('✅ Sincronización completada:', result);
      return result;
    } catch (error) {
      console.error('❌ Error en sincronización:', error);
      throw error;
    }
  });

/**
 * Cloud Function: Sincronizar manualmente (HTTP trigger)
 * 
 * Uso: POST /syncCertifications
 * Requiere autenticación con Firebase Custom Token
 */
exports.syncCertifications = functions
  .region('us-central1')
  .https.onRequest(async (req, res) => {
    // Verificar que la solicitud viene de Firebase
    if (!req.body.authToken) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    try {
      const folderId = process.env.GOOGLE_DRIVE_FOLDER_ID;
      if (!folderId) {
        throw new Error('GOOGLE_DRIVE_FOLDER_ID no configurada');
      }

      const auth = new google.auth.GoogleAuth({
        scopes: ['https://www.googleapis.com/auth/drive.readonly'],
      });

      const files = await listFilesInFolder(folderId, auth);
      
      const certRef = db.ref('Certifications');
      const currentCerts = (await certRef.get()).val() || {};

      let synced = 0, created = 0, updated = 0;

      for (const file of files) {
        const { id: fileId, name: fileName } = file;
        const certName = extractCertName(fileName);

        let existingId = null;
        for (const [certId, certData] of Object.entries(currentCerts)) {
          if (certData.driveFileId === fileId) {
            existingId = certId;
            break;
          }
        }

        const certData = {
          name: certName,
          driveFileId: fileId,
          description: `Sincronizado manualmente - ${new Date().toLocaleDateString()}`,
          lastSyncedAt: Date.now(),
        };

        if (existingId) {
          await certRef.child(existingId).update(certData);
          updated++;
        } else {
          const newId = certRef.push().key;
          await certRef.child(newId).set(certData);
          created++;
        }
        synced++;
      }

      return res.status(200).json({
        message: 'Sync completed',
        synced,
        created,
        updated,
      });
    } catch (error) {
      console.error('Error:', error);
      return res.status(500).json({ error: error.message });
    }
  });
