importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDz7nDrMC0WDRWTztaiRkhL6Z66PEqOorw",
  authDomain: "taxicab-310e5.firebaseapp.com",
  projectId: "taxicab-310e5",
  messagingSenderId: "780109363976",
  appId: "1:780109363976:web:23377a3db5a005e0d7cabd"
});

const messaging = firebase.messaging();
