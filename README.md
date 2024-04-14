# Wasabi
What's up b

A text and VoIP application focused on streamlining workflow for users through built-in collaborative features.

**(Discord + Google Drive)**

# Features
- Real-time messaging using Socket.IO
- Communication through messaging, voice or video calls
- Encryption for 1:1 conversations
- Collaborative document editing and whiteboard
- Integrated calendars and checklists
- Create and present slides

# Prerequisites
- **Node version 20.x.x**
- **Flutter**

# Getting Started

- Clone the repository

```shell
git clone https://github.com/CrimsX/Wasabi
```

- Create server .env file
```shell
DATABASE_URL=

AES_KEY=

PUBLIC_LIVEKIT_URL=
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
```

- Create databases

```shell
mysql
source schema.sql;
source insertData.sql; (optional)
```

- Start the server

```shell
npm i --production
npm start
```

- Start the app

```shell
flutter pub get
flutter run
```
