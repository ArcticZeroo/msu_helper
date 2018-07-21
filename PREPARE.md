# Preparing an app release

## `android/app/build.gradle` :

Navigate to android/defaultConfig
- Update versionCode
- Update versionName

## Signing

Put the private key somewhere.

Make `key.properties` with the body:

```
storePassword=KEY_PASS
keyPassword=KEY_PASS
keyAlias=key
storeFile=KEY_PATH
```

## Commands

Probably should run build-json-serializable, but not necessary

Run `flutter build apk`

