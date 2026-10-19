# Google sign-in: one-time Google Cloud setup

NutriLoop signs people in with Google and backs up each person's data to a hidden app folder in
**their own** Google Drive (scopes `drive.appdata`, `email`, `profile`). Google only allows that once
this setup exists. Do it once, in your own Google account. Your friends don't need to do anything.

| Value | |
|---|---|
| Package name | `com.shyamal.nutriloop` |
| SHA-1 signing fingerprint | `7A:81:5F:2A:F9:39:5B:3E:08:E5:1B:38:EB:0E:A1:78:68:12:41:20` |

1. Open https://console.cloud.google.com and sign in with your Gmail.
2. Top bar → project picker → **New project** → name `NutriLoop` → **Create**, then select it.
3. Search **Google Drive API** → open it → **Enable**.
4. Left menu → **Google Auth Platform** (older screens: APIs & Services → OAuth consent screen) → **Get started**:
   - App name `NutriLoop`, support email = your Gmail → Next
   - Audience: **External** → Next
   - Contact email = your Gmail → Next → agree → **Create**
5. **Data access** → **Add or remove scopes** → tick `.../auth/drive.appdata`, `.../auth/userinfo.email`
   and `.../auth/userinfo.profile` (search for them, or paste them in "Manually add scopes") → Update → **Save**.
6. **Clients** → **Create client** → Application type **Android**:
   - Name `NutriLoop Android`
   - Package name `com.shyamal.nutriloop`
   - SHA-1 fingerprint from the table above → **Create**
7. **Audience** → click **Publish app** → Confirm.
   This matters for friends: while the app is in "Testing", only Gmail addresses listed as test users
   can sign in. Once published, anyone can. All three scopes are non-sensitive, so Google doesn't
   need to review the app. Friends may see a note that the app isn't verified; they tap through it.

Nothing needs to be copied back into the app: Google matches it by package name + SHA-1.

If the app says "Google setup not finished", the Android client in step 6 is missing, or its package
name or SHA-1 doesn't match. The signing key is saved in `C:\Users\bhatt\android-build\KEEP-SAFE-signing-key`.
