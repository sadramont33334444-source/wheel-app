# گردونه شانس - اپلیکیشن آفلاین Flutter

اپلیکیشن حرفه‌ای گردونه شانس با قابلیت محدودیت 3 بار چرخش در هر 24 ساعت

## ویژگی‌های اصلی

✅ **کاملاً آفلاین** - بدون نیاز به اینترنت (به جز لینک تلگرام)  
✅ **8 بخش متفاوت** - شامل جوایز واقعی و بخش‌های پوچ  
✅ **انیمیشن نرم و حرفه‌ای** - با easeOut curve  
✅ **جلوگیری از اسپم کلیک** - غیرفعال شدن دکمه در حین چرخش  
✅ **محدودیت زمانی** - 3 بار چرخش در هر 24 ساعت  
✅ **افکت confetti** - برای برد جایزه  
✅ **صدای آفلاین** - صدای چرخش و برد  
✅ **تایمر باقی‌مانده** - نمایش زمان تا ریست شدن  

## ساختار پروژه

```
lib/
├── models/
│   └── prize_item.dart           # مدل جوایز گردونه
├── services/
│   ├── spin_limit_service.dart   # سرویس محدودیت 24 ساعته
│   └── audio_service.dart         # سرویس پخش صدا
├── widgets/
│   └── fortune_wheel.dart         # ویجت گردونه و نشانگر
├── screens/
│   └── home_screen.dart           # صفحه اصلی
└── main.dart                      # نقطه شروع برنامه

assets/
└── audio/
    ├── spin.mp3                   # صدای چرخش (باید اضافه شود)
    └── win.mp3                    # صدای برد (باید اضافه شود)
```

## نصب و راه‌اندازی

### پیش‌نیازها
- Flutter SDK 3.11.0 یا بالاتر
- Android SDK برای ساخت APK

### مراحل نصب

1. **کلون کردن پروژه**
```bash
cd fortune_wheel_app
```

2. **نصب وابستگی‌ها**
```bash
flutter pub get
```

3. **اضافه کردن فایل‌های صوتی**
   - دو فایل صوتی `spin.mp3` و `win.mp3` را در پوشه `assets/audio/` قرار دهید
   - منابع رایگان صدا:
     - [Freesound](https://freesound.org)
     - [Mixkit](https://mixkit.co)
     - [Zapsplat](https://zapsplat.com)

4. **اجرای برنامه**
```bash
flutter run
```

## ساخت APK برای انتشار

### 1. ساخت APK نسخه Release

```bash
flutter build apk --release
```

فایل APK در مسیر زیر ایجاد می‌شود:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 2. ساخت App Bundle (توصیه شده برای Google Play)

```bash
flutter build appbundle --release
```

### 3. ساخت APK برای معماری‌های مختلف (سایز کوچک‌تر)

```bash
flutter build apk --split-per-abi --release
```

این دستور 3 فایل APK جداگانه ایجاد می‌کند:
- `app-armeabi-v7a-release.apk` (برای دستگاه‌های قدیمی)
- `app-arm64-v8a-release.apk` (برای دستگاه‌های مدرن)
- `app-x86_64-release.apk` (برای امولاتور)

## انتشار در کافه‌بازار و مایکت

### آماده‌سازی برای انتشار

1. **تغییر نام بسته (Package Name)**
   - فایل: `android/app/build.gradle`
   - تغییر `applicationId` به نام یکتا (مثلاً `com.yourcompany.fortunewheel`)

2. **افزایش شماره نسخه**
   - فایل: `pubspec.yaml`
   - تغییر `version: 1.0.0+1` به نسخه جدید (مثلاً `1.0.1+2`)

3. **امضای APK (مهم برای انتشار)**

   الف) ایجاد keystore:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   ب) ایجاد فایل `android/key.properties`:
   ```properties
   storePassword=<رمز keystore>
   keyPassword=<رمز key>
   keyAlias=upload
   storeFile=<مسیر به upload-keystore.jks>
   ```

   ج) تنظیم `android/app/build.gradle`:
   ```gradle
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }

   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **آماده‌سازی اطلاعات فروشگاه**
   - عنوان: گردونه شانس
   - توضیحات کوتاه: گردونه شانس روزانه با جوایز واقعی
   - توضیحات کامل: (توضیحات جذاب درباره برنامه)
   - اسکرین‌شات‌ها: حداقل 4 عکس از برنامه
   - آیکون: طراحی آیکون حرفه‌ای 512x512 پیکسل

### انتشار در کافه‌بازار

1. ثبت‌نام در [پنل توسعه‌دهندگان کافه‌بازار](https://cafebazaar.ir/developers)
2. ایجاد اپلیکیشن جدید
3. آپلود APK یا App Bundle امضا شده
4. تکمیل اطلاعات (عنوان، توضیحات، تصاویر، دسته‌بندی)
5. ارسال برای بررسی

### انتشار در مایکت

1. ثبت‌نام در [پنل توسعه‌دهندگان مایکت](https://developer.myket.ir)
2. ایجاد برنامه جدید
3. آپلود APK امضا شده
4. تکمیل اطلاعات برنامه
5. ارسال برای بررسی

## توضیحات فنی

### سیستم محدودیت 24 ساعته

برنامه از `SharedPreferences` استفاده می‌کند تا:
- تعداد چرخش‌های امروز را ذخیره کند
- زمان اولین چرخش را ثبت کند
- دقیقاً بعد از 24 ساعت ریست شود (نه فقط تغییر روز)

### انیمیشن گردونه

- از `AnimationController` با `CurvedAnimation(easeOut)` استفاده می‌شود
- نتیجه قبل از شروع انیمیشن تعیین می‌شود
- زاویه دقیق محاسبه می‌شود تا بخش انتخابی دقیقاً زیر نشانگر قرار گیرد
- 5 دور کامل + زاویه دقیق = انیمیشن طبیعی

### جلوگیری از اسپم کلیک

متغیر `_isSpinning` دکمه را در حین چرخش غیرفعال می‌کند.

## تست برنامه

قبل از انتشار:
1. تست روی دستگاه واقعی (نه فقط امولاتور)
2. بررسی عملکرد محدودیت 24 ساعته
3. تست صداها
4. بررسی نمایش صحیح فونت فارسی
5. تست لینک تلگرام
6. بررسی عملکرد در اندازه صفحه‌های مختلف

## مجوزها

این اپلیکیشن فقط از این مجوزها استفاده می‌کند:
- `INTERNET` - فقط برای باز کردن لینک تلگرام
- `QUERY_ALL_PACKAGES` - برای `url_launcher`

## پشتیبانی

برای ارتباط: [@tolmno](https://t.me/tolmno)

## نسخه

**1.0.0** - نسخه اولیه

---

**نکات مهم:**
- حتماً قبل از انتشار، فایل‌های صوتی را اضافه کنید
- APK را امضا کنید
- اسکرین‌شات‌های با کیفیت تهیه کنید
- توضیحات جذاب و کامل بنویسید
