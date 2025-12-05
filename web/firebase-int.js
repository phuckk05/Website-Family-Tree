// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
    apiKey: "AIzaSyDNhrySr79meukkK7D59isSrfoihApLSdI",
    authDomain: "website-gia-pha-6eca4.firebaseapp.com",
    projectId: "website-gia-pha-6eca4",
    storageBucket: "website-gia-pha-6eca4.firebasestorage.app",
    messagingSenderId: "340219657596",
    appId: "1:340219657596:web:c94f8dc7a52d3d0132f8f9",
    measurementId: "G-X7MWYRDJRQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
