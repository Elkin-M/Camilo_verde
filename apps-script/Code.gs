const CONFIG = {
  folderId: '1AKEKFUSvlDSfESNxRkKVCxaVpbU9nu6F',
  folders: { evidence: 'evidencias', model: 'modelos-3d' },
  firebaseProjectId: 'camilo-verde-87f45',
  firebaseApiKey: 'AIzaSyAWjZ5XH8DCXoYnBRheJ2dIO390p7-qdtE',
};

function doPost(event) {
  try {
    const request = JSON.parse(event.postData.contents);
    const token = request.idToken;
    if (!token) return response({ error: 'Falta el token de Firebase.' }, 401);
    const firebaseUser = verifyFirebaseToken(token);
    if (!firebaseUser) return response({ error: 'Token de Firebase inválido.' }, 401);
    const admin = getAdmin(firebaseUser.localId, token);
    if (!admin || admin.active !== true) return response({ error: 'El usuario no es un administrador activo.' }, 403);

    if (request.action === 'trash') {
      if (!request.fileId) return response({ error: 'Falta el ID del archivo.' }, 400);
      DriveApp.getFileById(request.fileId).setTrashed(true);
      return response({ success: true, fileId: request.fileId });
    }
    if (!request.file || !request.file.base64 || !request.file.name) return response({ error: 'No se recibió ningún archivo.' }, 400);
    const blob = Utilities.newBlob(Utilities.base64Decode(request.file.base64), request.file.contentType || 'application/octet-stream', request.file.name);
    const parent = DriveApp.getFolderById(CONFIG.folderId);
    const folderName = request.folder === 'model' ? CONFIG.folders.model : CONFIG.folders.evidence;
    const target = getOrCreateFolder(parent, folderName);
    const file = target.createFile(blob);
    file.setSharing(DriveApp.Access.ANYONE_WITH_LINK, DriveApp.Permission.VIEW);
    return response({ url: publicFileUrl(file.getId(), file.getMimeType()), fileId: file.getId(), mimeType: file.getMimeType() }, 201);
  } catch (error) {
    console.error(error);
    return response({ error: 'No se pudo procesar el archivo: ' + error.message }, 500);
  }
}

function verifyFirebaseToken(idToken) {
  const result = UrlFetchApp.fetch('https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' + CONFIG.firebaseApiKey, { method: 'post', contentType: 'application/json', payload: JSON.stringify({ idToken: idToken }), muteHttpExceptions: true });
  if (result.getResponseCode() !== 200) return null;
  const users = JSON.parse(result.getContentText()).users || [];
  return users.length ? users[0] : null;
}

function getAdmin(uid, idToken) {
  const url = 'https://firestore.googleapis.com/v1/projects/' + CONFIG.firebaseProjectId + '/databases/(default)/documents/admins/' + uid;
  const result = UrlFetchApp.fetch(url, { headers: { Authorization: 'Bearer ' + idToken }, muteHttpExceptions: true });
  if (result.getResponseCode() !== 200) return null;
  const fields = JSON.parse(result.getContentText()).fields || {};
  return { active: fields.active && fields.active.booleanValue === true, role: fields.role && fields.role.stringValue };
}

function getOrCreateFolder(parent, name) {
  const folders = parent.getFoldersByName(name);
  return folders.hasNext() ? folders.next() : parent.createFolder(name);
}

function publicFileUrl(fileId, mimeType) {
  return mimeType.indexOf('image/') === 0 ? 'https://drive.google.com/thumbnail?id=' + fileId + '&sz=w2000' : 'https://drive.google.com/uc?export=download&id=' + fileId;
}

function response(body, status) {
  return ContentService.createTextOutput(JSON.stringify(body)).setMimeType(ContentService.MimeType.JSON);
}
