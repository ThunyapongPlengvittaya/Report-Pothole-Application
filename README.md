# วีธีการใช้งาน report pothole mobile application โดยเครื่องที่ใช้พัฒนาจะเป็นระบบ macOS ชิป M3

## ข้อกำหนดเบื้องต้น

- mobile application นี้จะใช้ flutter จึงจำเป็นจะต้องมี complier สำหรับภาษา dart สามารถ download ได้ที่นี่ [Flutter installation](https://docs.flutter.dev/get-started/install)
- เป็นระบบ iOS ดังนั้นจึงจะต้องใช้ Xcode ในการทดสอบการใช้งานซึ่งจะมีแค่ในระบบ macOS เท่านั้น

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

## ขั้นตอนการเปิดใช้งาน Xcode ใน iphone simulator หรือ เครื่อง iphone

- ไปที่ folder ios และเปิดไฟล์ Runner.xcworkspace ใน Xcode
- จากนั้นกด run และรอให้ build ขึ้น succeeded
- ทดลองใช้งาน report pothole mobile application



