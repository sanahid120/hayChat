# HayChat

HayChat is an Android Flutter messaging app. Firebase Authentication manages accounts, and Cloud Firestore stores shared conversations and messages.

## Chat data model

- `conversations/{conversationId}` is one shared document per one-to-one chat. It contains the two member IDs, participant display data, the latest message preview, and unread/read state keyed by user ID.
- `conversations/{conversationId}/messages/{messageId}` stores each message once. Both chat participants read the same message document.
- `users/{userId}/fcmTokens/{tokenId}` stores push tokens for the signed-in user's devices.
- Existing `userChats/{userId}/conversations` preview documents are copied into the shared conversation document on the user's next sign-in, then removed.

## Push notifications and Firebase setup

The app displays Firebase Cloud Messaging notifications locally while it is in the foreground. The Cloud Function sends notification payloads so Android can display messages when the app is backgrounded or closed. Functions also synchronize participant names and profile image URLs in shared conversations.

Deploy the Firestore rules, composite index, and Functions to the Firebase project configured in `firebase.json`:

```sh
firebase deploy --only firestore:rules,firestore:indexes,functions
```

The Android project must use the matching `google-services.json`, and users must allow notifications on their device. Background delivery depends on the Cloud Functions being deployed.
