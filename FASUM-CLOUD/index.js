const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");
const serviceAccount = require("./serviceAccountKey.json");
const cors = require("cors");
require("dotenv/config");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});
const app = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

app.post("send-notification", async (req, res) => {
  const { token, title, body, senderName, senderPhotourl } = req.body;

  if (!token || !title || !body) {
    return res.status(400).json("token, title, body wajib diisi");
  }
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      title: title || "Notification Baru",
      body: body || "Anda memiliki notification Baru",
      senderName: senderName || "Admin",
      senderPhotourl: senderPhotourl || "",
      sendAt: new Date().toISOString(),
      messageType: "topic-notification",
    },
    android: {
      priority: "high",
    },
    apns: {
      Headers: {
        "apns-priority": "10",
      },
    },
  };
  try {
    const response = await admin.messaging().send(message);
    res.status(200).json({
      success: true,
      message: `Notification berhasil dikirim ke topic '$(topic)`,
      response: response,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});
const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log("Server running on ${PORT}");
});
