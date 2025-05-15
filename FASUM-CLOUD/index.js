const express = require("express");
const admin = require("firebase-admin");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const app = express();

// ✅ Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ✅ Load service account from .env
const serviceAccountPath = path.resolve(
  __dirname,
  process.env.SERVICE_ACCOUNT_KEY
);

let serviceAccount;
try {
  serviceAccount = require(serviceAccountPath);
} catch (error) {
  console.error("❌ Gagal memuat service account key:", error.message);
  process.exit(1); // Hentikan server jika gagal
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// ✅ Test route
app.get("/", (req, res) => {
  res.send("✅ Fasum Cloud server is running!");
});

// ✅ POST /send-to-topic route
app.post("/send-to-topic", async (req, res) => {
  const { topic, title, body, senderName, senderPhotoUrl } = req.body;

  if (!topic || !title || !body) {
    return res
      .status(400)
      .json({ error: "topic, title, and body are required." });
  }

  const message = {
    topic,
    notification: {
      title,
      body,
    },
    data: {
      title,
      body,
      senderName: senderName || "Admin",
      senderPhotoUrl: senderPhotoUrl || "",
      sendAt: new Date().toISOString(),
      messageType: "topic-notification",
    },
    android: {
      priority: "high",
    },
    apns: {
      headers: {
        "apns-priority": "10",
      },
    },
  };

  try {
    const response = await admin.messaging().send(message);
    res.status(200).json({
      success: true,
      message: `✅ Notifikasi berhasil dikirim ke topic '${topic}'`,
      response,
    });
  } catch (error) {
    console.error("❌ Error saat mengirim notifikasi:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// ✅ Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running at http://localhost:${PORT}`);
});
