Google Sign-In (Better Auth) — Web OAuth client ID

The project includes assets/secrets/google_web_client_id.txt with a placeholder
line. Replace that line with your real Web client id (same as API GOOGLE_CLIENT_ID),
or delete the placeholder and paste your id as the only non-comment line.
The word PASTE_ in a line is treated as not configured.

Full app restart (not hot reload) is required after you change this file or add
it for the first time, so Flutter can rebundle assets.

You can also use:
  flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_ID.apps.googleusercontent.com

Register your app’s SHA-1 in Google Cloud for the Android OAuth client.
