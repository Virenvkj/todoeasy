# 🚀 How to Create a Signed App Bundle for Flutter (for Play Store Upload)

Follow these steps to build and sign your Flutter app for release on the Google Play Store.

---

## 🧹 Step 1: Clean and Prepare the Project

```bash
flutter pub cache clear
flutter clean
flutter pub get
```

---

## 🏗️ Step 2: Open the Android Project in Android Studio

1. In your Flutter project, **right-click the `android/` folder**.
2. Select **“Open in Android Studio.”**

---

## 🔄 Step 3: Sync Gradle

1. Once Android Studio opens, perform a **Gradle sync**.
2. **Fix any errors** that occur during the sync.
3. When the sync is successful, run the following command to ensure the build works:

```bash
flutter build apk
```

4. Resolve any build errors before continuing.

---

## 🔐 Step 4: Generate a Signed App Bundle

1. In Android Studio, go to  
   **Build → Generate Signed Bundle / APK.**
2. Select **“Android App Bundle.”**
3. Choose one of the following:
   - **New Release:** Create a new keystore.
   - **Update Release:** Use an existing keystore.
4. Enter your **keystore credentials and path**.  
   This will create a `.jks` file (Java Keystore).

---

## ⚙️ Step 5: Update Project Configuration

### 1. Update `android/local.properties`
Ensure you have the correct `versionCode` and `versionName`.

### 2. Create a `android/key.properties` file
Add your keystore credentials:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-your-keystore-file>.jks
```

---

## 🧾 Step 6: Configure Signing in Gradle

### 1. Open `android/app/build.gradle`

At the **top** of the file, load the key properties:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### 2. Inside the `android {}` block, add signing configurations:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### 3. Under `buildTypes`, link the release signing config:

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## 🧩 Step 7: Build the Signed App Bundle

1. In Android Studio, open  
   **Build → Generate Signed Bundle / APK.**
2. Choose **Android App Bundle**.
3. Select your **existing keystore**.
4. Enter the **keystore password**.
5. Choose the **Release** build type.
6. Click **Finish**.

After a few minutes, your signed **`.aab` (App Bundle)** file will be generated inside:

```
android/app/release/
```

---

## ✅ Final Output

You now have a **signed App Bundle (`.aab`)** ready to upload to the **Google Play Console** under your app’s release section.
