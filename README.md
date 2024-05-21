## Directory Tree

```plaintext
Pothole-flutter/
├── assets/
├── ios/
├── lib/
│   ├── auth/
│   │   ├── auth.dart
│   │   └── login_or_register.dart
│   ├── components/
│   │   ├── my_button.dart
│   │   └── my_textfield.dart
│   ├──  page/
│   │   ├── admin/
│   │   │   ├── pothole/
│   │   │   │   ├── admin_first_page.dart
│   │   │   │   ├── admin_home_page.dart
│   │   │   │   └── admin_second_page.dart
│   │   ├── user/
│   │   │   ├── user_history.dart
│   │   │   ├── user_home_page.dart
│   │   │   ├── user_main.dart
│   │   │   ├── user_maps.dart
│   │   │   └── user_profile.dart
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── splash_page.dart
│   ├── firebase_options.dart
│   └── main.dart
├── .flutter-plugins
├── .flutter-plugins-dependencies
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
└── README.md

python-mobilenet/
├── __pycache__/
│   └── mobilenet.cpython-311.pyc
├── Dockerfile
├── mobilenet.py
├── pothole_3.h5
└── server.py

```


# วีธีการใช้งาน report pothole mobile application โดยเครื่องที่ใช้พัฒนาจะเป็นระบบ macOS ชิป M3

## ข้อกำหนดเบื้องต้น

- mobile application นี้จะใช้ flutter จึงจำเป็นจะต้องมี complier สำหรับภาษา dart สามารถ download ได้ที่นี่ [Flutter installation](https://docs.flutter.dev/get-started/install)
- เป็นระบบ iOS ดังนั้นจึงจะต้องใช้ Xcode ในการทดสอบการใช้งานซึ่งจะมีแค่ในระบบ macOS เท่านั้น
- หากต้องการใช้งานในเครื่อง iphone แบบ physical จะต้องมี Xcode developer account 

## ขั้นตอนการตั้งค่าเริ่มต้น

- clone ทั้ง folder
- เข้าไปที่ไฟล์ GoogleService-Info.plist จากนั้นก็เอา google maps api key ของตัวเองใส่ลงไปในช่อง string ใต้ API_KEY
- 
## ขั้นตอนการดาวโหลด dependencies and packages ที่จำเป็น

- ดาวโหลด dependencies ของ flutter จะใช้คำสั่งใน terminal ดังนี้

```bash
flutter pub get
```

- หลังจาก download แล้วก็ให้ไปที่ folder ios เพื่อทำการติดตั้ง packages สำหรับใช้งาน ios ดังนี้

```bash
pod install
```

## ขั้นตอนการเปิดใช้งาน Report pothole application เฉพาะใน iOS device simulator 
- สร้าง simulator device ที่เป็น iphone version ไหนก็ได้ขึ้นมา
- เปิด terminal ใน folder ของโปรเจคขึ้นมา แล้วรัน command ดังนี้

```bash
flutter run
```
- รอให้แอปพลิเคขันเปิดขึ้นมา

## ขั้นตอนการเปิดใช้งาน Xcode ใน physical iphone

- ไปที่ folder ios และเปิดไฟล์ Runner.xcworkspace ใน Xcode
- จากนั้นกดปุ่ม run และรอให้ build ขึ้น succeeded
- ทดลองใช้งาน report pothole mobile application

## ขั้นตอนการทดสอบระบบ
- เข้าสู่ระบบในสถานะ admin โดยจะใช้ email และ password ดังนี้
```bash
admin@gmail.com
cstu65
```
- เข้าสู่ระบบในสถานะ user สามารถสมัครได้เลย


