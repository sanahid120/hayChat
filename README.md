# HayChat

HayChat is a Flutter messaging app for Android. Users can create an account, find people by email, and have real-time one-to-one conversations. Firebase provides authentication, chat storage, presence, and push delivery.

## Features

- Email and password registration and sign-in
- Password reset by email
- Find users by email and start a conversation
- Real-time one-to-one text messaging
- Shared conversation history: each message is stored once for both participants
- Conversation previews, timestamps, per-chat unread counts, and a total unread badge
- Sent, delivered, and read indicators
- Online status and last active time in the chat header
- Profile photo selection and upload to Cloudinary
- Foreground local notifications and Firebase push notifications when the app is in the background
- Contact profile updates synchronized to existing conversations
- Automatic migration of older per-user conversation previews when a user signs in

## Technology

| Area | Technology |
| --- | --- |
| App | Flutter and Dart |
| State management | Provider |
| Authentication | Firebase Authentication |
| Chat, profiles, presence | Cloud Firestore |
| Push delivery | Firebase Cloud Messaging and Firebase Cloud Functions |
| Foreground notifications | `flutter_local_notifications` |
| Profile image storage | Cloudinary unsigned image upload |
| Backend runtime | Node.js 20 with Firebase Admin SDK and Firebase Functions SDK |

## How chat data is stored

HayChat uses a shared conversation document instead of keeping a separate copy of each chat preview for each participant:

```text
users/{userId}
  fcmTokens/{tokenId}
  presence/{sessionId}

conversations/{conversationId}
  messages/{messageId}
```

- `conversations/{conversationId}` contains the two member IDs, participant display data, latest-message preview, and read and unread state.
- `conversations/{conversationId}/messages/{messageId}` contains each message once. Both participants read the same message document.
- `users/{userId}/presence/{sessionId}` stores a per-device session heartbeat. The app refreshes it while foregrounded; a stale heartbeat is treated as offline.
- `users/{userId}/fcmTokens/{tokenId}` stores the signed-in user's push tokens.
- Older data in `userChats/{userId}/conversations` is migrated to the shared conversation model on sign-in.

Conversation IDs are created from the two user IDs in sorted order, so both participants resolve to the same conversation.

## Requirements

- A Flutter SDK whose bundled Dart SDK satisfies the constraint in `pubspec.yaml` (`^3.11.0`)
- Android SDK and Java 17 for Android builds
- A Firebase project with Authentication, Cloud Firestore, and Cloud Messaging configured
- Node.js 20 and the Firebase CLI to deploy backend resources
- A Cloudinary account with an unsigned image upload preset for profile photo uploads

The Firebase client configuration in this workspace targets Android. To use another Firebase project, provide its `android/app/google-services.json`, regenerate `lib/firebase_options.dart` with FlutterFire CLI, and select the intended project in `.firebaserc`.

## Run the app

From the repository root:

```sh
flutter pub get
flutter run
```

Enable the **Email/Password** provider in Firebase Authentication and create a Cloud Firestore database before signing in. On Android, allow HayChat notifications in the system permission prompt or app settings.

## Configure Cloudinary

Profile photos are uploaded directly from the app using the unsigned Cloudinary preset named `haychat`. Configure the cloud name in `lib/app/urls.dart` and make sure the preset is enabled for unsigned uploads in the Cloudinary console. Do not place Cloudinary API secrets in the mobile app.

## Deploy Firebase resources

The Firebase configuration in `firebase.json` points to the project selected in `.firebaserc`. From the repository root, install the Functions dependencies and deploy the Firestore rules, indexes, and message/profile functions:

```sh
cd functions
npm install
cd ..
firebase deploy --only firestore:rules,firestore:indexes,functions
```

The Functions deployment is required for notifications while the app is backgrounded or closed and for syncing updated profile details into conversation previews. The Firestore rules deployment is required for chat, token registration, and presence access. The `messages` composite index supports unread-message lookups; Firestore may take a short time to build it after deployment.

## Project layout

```text
lib/
  app/                 App theme, routes, and shared models
  auth/                Authentication screens, providers, and chat repository
  core/services/       Notification and presence services
  features/chat/       Conversation screen, message model, and chat provider
  features/contacts/   Contact search and recent conversations
  features/home/       Conversation list and unread summary
  features/profile/    Profile display and photo upload
  shared/              Bottom navigation and shared utilities
functions/             Firebase Cloud Functions
android/               Android app and Firebase client configuration
firestore.rules         Firestore access rules
firestore.indexes.json  Firestore composite indexes
```

## Current scope

The configured client target is Android. The app currently provides one-to-one text chats; video calling and ZegoCloud are not part of the project.
