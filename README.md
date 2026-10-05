# কালান্তর প্রকাশনী — অ্যান্ড্রয়েড অ্যাপ (Flutter)

kalantorprokashoni.com ওয়েবসাইটকে WebView-তে চালানো অ্যাপ। সাইটে যা বদলাবেন, অ্যাপে নিজে থেকেই দেখাবে।

## APK বানানোর সহজ উপায় (GitHub Actions)
1. github.com-এ একটা নতুন (private হলেও চলবে) রিপো খুলুন।
2. এই ফোল্ডারের সব ফাইল (`.github` সহ) আপলোড/পুশ করুন, ব্রাঞ্চ `main`।
3. রিপোর **Actions** ট্যাবে "Build APK" চলবে (৫–৮ মিনিট)।
4. শেষ হলে রান খুলে নিচে **Artifacts → kalantor-apk** ডাউনলোড করুন, জিপের ভেতরে `app-release.apk`।

## নিজের পিসিতে বানাতে
```
flutter create --platforms=android --org com.kalantorprokashoni --project-name kalantor_app .
# (pubspec.yaml ও lib/main.dart আগের ফাইল দিয়ে রিস্টোর করুন)
# android/app/src/main/AndroidManifest.xml-এ <application এর আগে যোগ করুন:
#   <uses-permission android:name="android.permission.INTERNET"/>
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```
APK: `build/app/outputs/flutter-apk/app-release.apk`
