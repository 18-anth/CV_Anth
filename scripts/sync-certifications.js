#!/usr/bin/env node

/**
 * 📁 Sincroniza automáticamente certificaciones desde Google Drive a Firebase
 *
 * Uso:
 *   node scripts/sync-certifications.js
 *
 * Variables de entorno requeridas:
 *   - GOOGLE_APPLICATION_CREDENTIALS: ruta al service account JSON
 *   - FIREBASE_DATABASE_URL: URL de tu Firebase Realtime Database
 *   - REACT_APP_GOOGLE_DRIVE_FOLDER_ID: ID de la carpeta de certificaciones en Drive
 */

const admin = require('firebase-admin');
const { google } = require('googleapis');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// ─── CONFIGURACIÓN ───────────────────────────────────────────────────────────

const GOOGLE_DRIVE_FOLDER_ID = process.env.REACT_APP_GOOGLE_DRIVE_FOLDER_ID;
const CREDENTIALS_PATH = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!GOOGLE_DRIVE_FOLDER_ID) {
    console.error('❌ Error: REACT_APP_GOOGLE_DRIVE_FOLDER_ID no está configurada');
    process.exit(1);
}

if (!CREDENTIALS_PATH) {
    console.error('❌ Error: GOOGLE_APPLICATION_CREDENTIALS no está configurada');
    process.exit(1);
}

// ─── INICIALIZAR SERVICIOS ──────────────────────────────────────────────────

// Firebase
const serviceAccount = JSON.parse(fs.readFileSync(CREDENTIALS_PATH, 'utf8'));
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.database();

// Google Drive
const auth = new google.auth.GoogleAuth({
    keyFile: CREDENTIALS_PATH,
    scopes: ['https://www.googleapis.com/auth/drive.readonly'],
});

const drive = google.drive({ version: 'v3', auth });

// ─── FUNCIONES ──────────────────────────────────────────────────────────────

/**
 * Lista todos los archivos de una carpeta de Google Drive
 */
async function listFilesInFolder(folderId) {
    try {
        const response = await drive.files.list({
            q: `'${folderId}' in parents and trashed=false and mimeType!='application/vnd.google-apps.folder'`,
            spaces: 'drive',
            fields: 'files(id, name, mimeType, webViewLink, createdTime)',
            pageSize: 100,
        });

        return response.data.files || [];
    } catch (error) {
        console.error('❌ Error al listar archivos de Drive:', error.message);
        throw error;
    }
}

/**
 * Extrae el nombre de la certificación del nombre del archivo
 * Ej: "AWS_Solutions_Architect.pdf" → "AWS Solutions Architect"
 */
function extractCertName(fileName) {
    return fileName
        .replace(/\.[^/.]+$/, '') // Elimina extensión
        .replace(/_/g, ' ') // Reemplaza _ con espacios
        .replace(/\b\w/g, (char) => char.toUpperCase()); // Capitaliza palabras
}

/**
 * Sincroniza los archivos de Drive con Firebase
 */
async function syncCertifications() {
    try {
        console.log('📁 Obteniendo archivos de Google Drive...');
        const driveFiles = await listFilesInFolder(GOOGLE_DRIVE_FOLDER_ID);
        console.log(`✅ Encontrados ${driveFiles.length} archivos en Drive`);

        if (driveFiles.length === 0) {
            console.log('⚠️  No hay archivos para sincronizar');
            return { synced: 0, updated: 0, created: 0 };
        }

        console.log('\n📝 Sincronizando con Firebase...');
        const certRef = db.ref('Certifications');
        const currentCerts = (await certRef.get()).val() || {};

        let synced = 0;
        let created = 0;
        let updated = 0;

        for (const file of driveFiles) {
            const { id: fileId, name: fileName } = file;
            const certName = extractCertName(fileName);

            // Buscar si ya existe una certificación con este driveFileId
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
                description: `Sincronizado desde Google Drive - ${new Date().toLocaleDateString()}`,
                createdAt: Date.now(),
            };

            try {
                if (existingId) {
                    // Actualizar existente
                    await certRef.child(existingId).update(certData);
                    updated++;
                    console.log(`  ✏️  Actualizado: ${certName}`);
                } else {
                    // Crear nuevo
                    const newId = certRef.push().key;
                    await certRef.child(newId).set(certData);
                    created++;
                    console.log(`  ✨ Creado: ${certName}`);
                }
                synced++;
            } catch (error) {
                console.error(`  ❌ Error al procesar ${certName}:`, error.message);
            }
        }

        console.log('\n✅ Sincronización completada:');
        console.log(`   • Total procesados: ${synced}`);
        console.log(`   • Creados: ${created}`);
        console.log(`   • Actualizados: ${updated}`);

        return { synced, updated, created };
    } catch (error) {
        console.error('❌ Error durante la sincronización:', error.message);
        throw error;
    } finally {
        // Cerrar conexión
        await admin.app().delete();
    }
}

// ─── EJECUTAR ────────────────────────────────────────────────────────────────

syncCertifications()
    .then((result) => {
        console.log('\n✅ Sincronización finalizada exitosamente');
        process.exit(0);
    })
    .catch((error) => {
        console.error('\n❌ Error fatal:', error);
        process.exit(1);
    });
