// Firebase Messaging Service Worker
// Requerido por Firebase Cloud Messaging para notificaciones en segundo plano

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyCi68BPrcnVz4fT0jLyaRhWy0SfqO9O0xw",
  authDomain: "portafolio-81169.firebaseapp.com",
  projectId: "portafolio-81169",
  storageBucket: "portafolio-81169.appspot.com",
  messagingSenderId: "299456829118",
  appId: "1:299456829118:web:efa9aec99843917cbd30ef",
  measurementId: "G-ME4KT7DB2S"
});

const messaging = firebase.messaging();

// Manejar mensajes en segundo plano
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Mensaje recibido en segundo plano:', payload);

  const notificationTitle = payload.notification?.title || 'Nueva notificación';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
