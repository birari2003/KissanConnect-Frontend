# Voice Recognition & Phone Call Setup Guide

## Overview
Voice recognition has been added to the following screens:
- **Send Email Widget**: Subject field, Message field, and AI chat input
- **Send WhatsApp Message Widget**: Message input field

## Phone Call Feature
A direct phone call feature has been added to:
- **Farmers List**: Each farmer card now has a phone icon button that opens the phone dialer with the farmer's contact number

## Features
- Tap the microphone icon to start voice recognition
- The icon turns red while listening
- Speech is converted to text in real-time
- Automatically stops after 3 seconds of silence or 30 seconds maximum
- Tap the microphone again to stop listening manually

## Platform-Specific Setup

### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.BLUETOOTH"/>
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
    
    <application>
        <!-- Add this inside the application tag -->
        <activity android:name="com.baseflow.permissionhandler.PermissionHandlerActivity"/>
    </application>
</manifest>
```

### iOS
Add the following to `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to the microphone for voice input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs access to speech recognition for voice input</string>
```

## Dependencies Added
- `speech_to_text: ^6.6.2` - For speech recognition
- `permission_handler: ^11.4.0` - For microphone permission handling

## Usage
1. Tap the microphone icon next to any text field
2. Grant microphone permission when prompted (first time only)
3. Start speaking
4. Your speech will be converted to text in real-time
5. The microphone will automatically stop after a pause or you can tap it again to stop

## Language Support
Currently configured for English (en_US). To add more languages, modify the `localeId` parameter in the `startListening` methods in:
- `lib/app/widhets/send_email.dart`
- `lib/app/widhets/send_whatsapp_message.dart`

Example for Hindi:
```dart
localeId: 'hi_IN',
```

## Troubleshooting
- **Permission denied**: Make sure you've added the platform-specific permissions
- **Not working on emulator**: Speech recognition may not work on some emulators, test on a real device
- **No speech detected**: Ensure your device microphone is working and not muted
