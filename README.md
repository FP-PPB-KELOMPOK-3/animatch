# Final Project Pemrograman Perangkat Bergerak (C)

## 📱 Animatch

Aplikasi *Tinder-like* untuk mencari karakter anime.

---

## 👥 Team Members
| Name                 | NRP        | Class                              |
| -------------------- | ---------- | ---------------------------------- |
| Mikhael Abie Saputra | 5025221113 | Pemrograman Perangkat Bergerak (C) |
| Adnan Abdullah Juan  | 5025221155 | Pemrograman Perangkat Bergerak (C) |
| Faiq Lidan Baihaqi   | 5025221294 | Pemrograman Perangkat Bergerak (C) |

- **Mikhael Abie Saputra** – _API service, tags(CRUD) service_
- **Adnan Abdullah Juan** – _Project setup, Firestore service, match(CRUD) service_
- **Faiq Lidan Baihaqi** – _FireAuth service, user(CRUD) service, navigation_

---

## 📝 Description
### Main Features
Fitur-fitur utama yang ada didalam aplikasi antara lain:
- Autentikasi user
- Update profile dan hapus akun user
- *Match* dengan karakter anime
- Menggunakan tags untuk search spesifik dan blacklist yang tidak sesuai dengan selera
- Melihat list karakter anime yang sudah di *match*, menghapus match, dan membuat karakter menjadi favorit

### Tech Stack
![Image](assets/documentation/Tech_Stack.png)

### Public API
Semua gambar karakter anime pada aplikasi ini diambil dari API publik **Nekosia.cat**.

Dokumentasi API publik Nekosia.cat:<br>https://nekosia.cat/documentation?page=api-endpoints#tags-endpoint

---

## 📸 Screenshots

### Login/Register screen
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/loginscreen.png" alt="description" width="250"/>
    <img src="assets/documentation/registerscreen.png" alt="login screen" width="250"/>
</div>

### Match screen
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/matchsreen.png" alt="register screen" width="250"/>
</div>

### Navigation drawer
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/navigationdrawer.png" alt="navigation drawer" width="250"/>
</div>

### Match list screen
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/matchlistscreen.png" alt="match list screen" width="250"/>
</div>

### Profile screen
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/profilescreen.png" alt="profile screen" width="250"/>
</div>

### Match demo
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/match_demo.gif" alt="match demo" width="250"/>
</div>

### Tags selection
<div style="display: flex; justify-content: space-evenly; align-items: center;">
    <img src="assets/documentation/tags_selection.gif" alt="tags selection" width="250"/>
</div>

---

## 🚀 Getting Started

run command berikut untuk menjalankan aplikasi untuk debug

```bash
flutter pub get
flutter run