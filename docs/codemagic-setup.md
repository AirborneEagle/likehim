# Codemagic CI setup — one-time

Like Him uses [Codemagic](https://codemagic.io) to build, sign, and upload both
iOS and Android straight from `main`, so we don't need a Mac on the dev machine
for iOS work. The pipeline lives in [`codemagic.yaml`](../codemagic.yaml).

This doc walks through the one-time setup. After it's done, every push (or
manual trigger) ships a build to TestFlight + Play internal track.

---

## 1. Sign up and connect the repo

1. Sign up at https://codemagic.io with your GitHub account.
2. Codemagic → **Add application** → connect to `AirborneEagle/likehim`.
3. When asked which workflow file to use, point at `codemagic.yaml` (auto-
   detected).

---

## 2. Apple — App Store Connect API key

In **App Store Connect → Users and Access → Integrations → App Store Connect API**:

1. Click **Generate API Key** (or **Add Key** if you already have some).
2. Name: `Codemagic CI`. Access: **App Manager**.
3. Download the `.p8` file — *you can only download it once*. Save it somewhere
   safe (1Password, encrypted folder).
4. Note the **Key ID** (~10-char string) and the **Issuer ID** (UUID at the top
   of the page).
5. Note your app's **Apple ID** (the numeric ID from App Store Connect → My Apps
   → Like Him → App Information → "Apple ID").

In **Codemagic → Apps → Like Him → Integrations → App Store Connect**:

1. Click **Connect** and paste the three values from above.
2. Name the integration `codemagic` (matches `integrations:` in the YAML).

---

## 3. Apple — Sign in with Apple Service ID

(Only needed once; pairs with [#9 — Sign in with Apple](https://github.com/AirborneEagle/likehim/issues/9).)

In **developer.apple.com → Certificates, Identifiers & Profiles → Identifiers**:

1. Click **+** → **Services IDs** → Continue.
2. Description: `Like Him Sign In`. Identifier: `dev.airborneeagle.likehim.signin`.
3. Continue → Register.
4. Open the new Service ID, enable **Sign In with Apple**, click Configure.
5. Primary App ID: `dev.airborneeagle.likehim`.
6. Domains and Subdomains: `like-him-app.firebaseapp.com`.
7. Return URLs: `https://like-him-app.firebaseapp.com/__/auth/handler`.

In **Firebase Console → Authentication → Sign-in method → Apple**:

1. Toggle **Enable**.
2. Services ID: `dev.airborneeagle.likehim.signin` (from above).
3. Apple Team ID: from developer.apple.com → Membership.
4. Key ID + Private Key: create a new Apple key from developer.apple.com →
   Keys, with **Sign In with Apple** enabled. Download the `.p8`, paste its
   contents into Firebase.
5. Save.

---

## 4. Google Play — service account

In **Google Cloud Console → IAM → Service Accounts**:

1. Create service account `codemagic-play-publisher`.
2. Grant role: none at the project level.
3. Click into the new account → Keys → Add Key → JSON → download.

In **Google Play Console → Setup → API access**:

1. If not already linked, link the Cloud project where you created the service
   account.
2. Find the service account in the list → Grant access.
3. Permissions:
   - **Releases**: Manage testing track releases (Internal / Closed) — yes
   - **App permissions**: Like Him only
4. Invite user → save.

---

## 5. Codemagic environment variables

In **Codemagic → Apps → Like Him → Environment variables**:

Create a group called `apple_keystore` (referenced as `keystore_reference` in
the YAML) with these secrets:

| Name | Value |
|---|---|
| `CM_KEYSTORE` | base64 of `android/app/likehim-upload-keystore.jks` |
| `CM_KEYSTORE_PASSWORD` | from your local `android/key.properties` → `storePassword` |
| `CM_KEY_ALIAS` | from `key.properties` → `keyAlias` |
| `CM_KEY_PASSWORD` | from `key.properties` → `keyPassword` |

Then create a second group (any name) with:

| Name | Value | Mark as secure? |
|---|---|---|
| `APP_STORE_CONNECT_PRIVATE_KEY` | contents of the `.p8` from step 2 | yes |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from step 2 | yes |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from step 2 | yes |
| `APP_STORE_APP_ID` | numeric Apple ID from step 2 | no |
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | full contents of the JSON from step 4 | yes |

To get the keystore as base64 (one-liner from a Mac or WSL):

```sh
base64 -w0 android/app/likehim-upload-keystore.jks | pbcopy
```

On Windows PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/likehim-upload-keystore.jks")) | Set-Clipboard
```

---

## 6. First build

1. **Codemagic → Like Him → Start new build**.
2. Pick `android-play-store` workflow → main branch → Start.
3. Should take ~12–15 min. On success: a new release in Play Console →
   Internal testing.
4. Repeat with `ios-app-store` workflow → ~20 min. On success: a new TestFlight
   build under Internal Testing.

---

## 7. Enable auto-build on push (optional)

Once both workflows have run green at least once, edit `codemagic.yaml` and
uncomment the `triggering:` blocks in each workflow. Then every push to `main`
ships a build to TestFlight + Play Internal automatically.
