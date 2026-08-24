<div align="rtl" dir="rtl">

<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### لانچر اپن‌سورس بازی؛ ساخته‌شده حول محور بازی‌های شما — نه یک فروشگاه

<p align="center">
  <a href="README.md">🇬🇧 English</a> •
  <b>🇮🇷 پارسی</b>
</p>

<p align="center">
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/voidone-ci.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/voidone-ci.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=white&label=CI%2FCD&color=7C3AED" alt="CI/CD Status"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases">
    <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?style=for-the-badge&logo=rocket&logoColor=white&color=FF2E63" alt="Latest Release"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=for-the-badge&logo=github&color=FFD700" alt="GitHub Stars"/>
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-FFD60A?style=for-the-badge" alt="MIT License"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/C%2B%2B-23-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++23"/>
  <img src="https://img.shields.io/badge/Qt-6.8-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt 6.8"/>
  <img src="https://img.shields.io/badge/QML-QtQuick-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt QML"/>
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Platform Support"/>
  <img src="https://img.shields.io/badge/SQLite-Local%20First-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite"/>
</p>

<br/>

**یک کتابخانه. بازی‌های شما. سخت‌افزار شما. قوانین شما.**

<br/>

<p align="center">
  <a href="#-voidone-چیست">درباره</a> •
  <a href="#-فلسفه-وجود">فلسفه</a> •
  <a href="#-ویژگی‌های-اصلی">ویژگی‌ها</a> •
  <a href="#-معماری-ghost-launch">گست‌لانچ</a> •
  <a href="#-عملکرد-و-کارایی">عملکرد</a> •
  <a href="#-معماری-سیستم">معماری</a> •
  <a href="#-نقشه-راه">نقشه راه</a> •
  <a href="#-ساخت-از-سورس">ساخت</a>
</p>

</div>

---

## 👁️ VoidOne چیست؟

**VoidOne** یک لانچر بازی و مدیریت‌کننده کتابخانه محلی (Local Library) آزاد، متن‌باز و بسیار سریع برای کامپیوتر است که از پایه با **C++23، Qt 6.8 و QML** توسعه یافته است.

دنیای بازی‌های کامپیوتر میان ده‌ها فروشگاه مختلف، سرویس‌های ردیابی پس‌زمینه، مرورگرهای وب سنگین درون‌برنامه‌ای و لانچرهای مختلف (Steam, Epic Games, GOG, EA, Ubisoft, Xbox) تکه‌تکه شده است.

پروژه VoidOne بازی‌های شما را از پیچیدگی و سنگینی فروشگاه‌ها جدا کرده و تمام عناوین نصب‌شده را تحت یک رابط کاربری نیتیو، زیبا، مدرن و حامی حریم خصوصی یکپارچه می‌کند.

> **بازی‌های شما باید مرکز توجه سیستم شما باشند — نه فروشگاه‌هایی که آن‌ها را توزیع می‌کنند.**

---

## 🛡️ فلسفه وجود

برنامه VoidOne بر پایه اصول مهندسی سخت‌گیرانه‌ای طراحی شده تا به سیستم و وقت کاربر احترام بگذارد:

* **♾️ کاملاً آزاد و متن‌باز:** تحت مجوز MIT. بدون اشتراک اجباری، بدون جمع‌آوری اطلاعات (Telemetry) و بدون هزینه‌های پنهان.
* **🔒 محلی‌محور و حامی حریم خصوصی:** تمام داده‌های کتابخانه، تاریخچه بازی و تنظیمات شما روی سیستم خودتان و در یک دیتابیس SQLite ذخیره می‌شوند.
* **📴 معماری آفلاین‌محور:** قابلیت‌های اصلی برنامه بدون نیاز به اینترنت کار می‌کنند. سرویس‌های آنلاین (مثل دریافت کاور و متاداده) فقط برای بهبود تجربه هستند و هرگز اجباری نیستند.
* **⚡ عملکرد نیتیو (قانون ۵۰ مگابایت رم):** ساختار کامپایل‌شده با C++/Qt و **بدون** استفاده از Electron یا مرورگر Chromium. هدف اصلی نگه داشتن مصرف رم در حالت Idle زیر **۵۰ مگابایت** است.

> *نکته:* پروژه VoidOne به‌هیچ‌عنوان سیستم‌های قفل یا DRM را دور نمی‌زند. اگر بازی خاصی به صورت قانونی نیاز به یک کلاینت جانبی داشته باشد، VoidOne آن وابستگی را رعایت می‌کند اما سنگینی اضافی لانچر را تا حد امکان کاهش می‌دهد.

---

## 🏗️ چشم‌انداز سیستم

برنامه VoidOne به عنوان یک **لایه مدیریت محلی یکپارچه** روی فروشگاه‌های مختلف قرار می‌گیرد:

```text
                    ┌─────────────────────┐
                    │       VoidOne       │
                    │   Unified Library   │
                    └──────────┬──────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
     Steam Games         Epic Games           GOG Games
          │                    │                    │
          └────────────────────┼────────────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Local Launch Engine │
                    └──────────┬──────────┘
                               │
                               ▼
                          🎮 Your Game
```

---

## ✨ ویژگی‌های اصلی

### 🎮 کتابخانه محلی یکپارچه
شناسایی خودکار بازی‌های نصب‌شده در فروشگاه‌ها و مسیرهای مختلف:
* فایل‌های Manifest و VDF استیم
* فایل‌های Manifest استور Epic Games
* ورودی‌های ریجستری GOG Galaxy
* مسیرهای دلخواه و اسکن پوشه‌های دستی

### 👻 معماری Ghost Launch
در صورت امکان، VoidOne فایل اجرایی بازی را بدون درگیر کردن رابط‌های سنگین فروشگاه‌ها به صورت مستقیم اجرا می‌کند.

```text
جریان سنتی:   User ──► Store Launcher ──► Background Services ──► Game
هدف VoidOne:  User ──► VoidOne ──► Game Binary
```

* پایش فرایند اجرا (Process Tracking) و مدیریت چرخه حیات بازی
* تنظیم آرگومان‌های اجرا و متغیرهای محیطی اختصاصی برای هر بازی
* پاک‌سازی خودکار پروسه‌ها و بازگرداندن وضعیت سیستم بعد از بستن بازی

### 🎨 رابط کاربری نیتیو با QML
* رندر کاملاً سخت‌افزاری و روان با Qt Quick
* طراحی تیره (Dark-First) و مدرن برای محیط دسکتاپ
* پشتیبانی کامل از کیبورد و گیم‌پد

### 🧩 معماری پیشرفته مدها (برنامه‌ریزی‌شده)
* نصب و اعمال مدها بدون آسیب به فایل‌های اصلی بازی (Non-destructive)
* پروفایل‌های مجزا برای مدها (مانند Vanilla, Visuals, Experimental)
* تشخصیص تداخل‌ها و مدیریت اولویت بارگذاری

---

## ⚡ مشخصات عملکرد

| معیار | هدف فنی | مکانیزم مهندسی |
| :--- | :--- | :--- |
| **رم در حالت Idle** | `< 50 MB` | مدیریت مستقیم حافظه در C++، بدون مرورگر داخلی |
| **زمان اجرا (Startup)** | `< 1.0s` | لود تدریجی UI و ترد‌های ناهمگام (Async C++) |
| **خوانش دیتابیس** | زیر میلی‌ثانیه | استفاده از SQLite با ایندکس‌های محلی بهینه‌شده |
| **رندرینگ** | 60+ FPS | شتاب‌دهی سخت‌افزاری با Qt Quick Scene Graph |

---

## 🏗️ معماری سیستم

برنامه VoidOne ساختار لایه‌ای کاملاً مجزایی میان هسته پردازشی، دیتابیس محلی و لایه گرافیکی QML حفظ می‌کند:

```text
┌─────────────────────────────────────────────┐
│              QML / Qt Quick UI              │
├─────────────────────────────────────────────┤
│         C++ Application / ViewModels        │
├─────────────────────────────────────────────┤
│       Game Discovery & Ghost Engine         │
├─────────────────────────────────────────────┤
│      Platform Scanners (Steam, GOG, Epic)   │
├─────────────────────────────────────────────┤
│            SQLite Persistence Layer         │
├─────────────────────────────────────────────┤
│          C++23 OS Abstraction Layer         │
├─────────────────────────────────────────────┤
│            Windows / Linux Kernel           │
└─────────────────────────────────────────────┘
```

---

## 🧰 تکنولوژی‌های استفاده‌شده

* **زبان هسته:** C++23 (MSVC 2022 / GCC 13+ / Clang 17+)
* **فریم‌ورک رابط کاربری:** Qt 6.8 (QML / Qt Quick)
* **پایگاه داده:** SQLite 3
* **سیستم ساخت:** CMake 3.25+ & Ninja
* **ابزارهای سنجش کیفیت:** AddressSanitizer, Cppcheck, GitHub CodeQL, Trivy
* **ارزیابی مداوم (CI/CD):** GitHub Actions (بیلد خودکار ویندوز و لینوکس)

---

## 🗺️ نقشه راه

- [x] **فاز ۱: زیرساخت**
  - [x] معماری ساخت پروژه با C++23 و CMake
  - [x] یکپارچه‌سازی موتور Qt 6.8 QML
  - [x] خط لوله CI/CD خودکار چندپلتفرمی
  - [x] ابزارهای تحلیل استاتیک و CodeQL

- [ ] **فاز ۲: شناسایی و ذخیره‌سازی** 🟡 *(در حال توسعه)*
  - [x] دیتابیس محلی SQLite
  - [ ] پارسر فایل‌های VDF استیم
  - [ ] اسکنر نصب Epic Games و GOG
  - [ ] اسکنر دستی فایل‌های اجرایی

- [ ] **فاز ۳: تجربه کتابخانه** ⚪
  - [ ] نمایش شبکه‌ای و لیستی با شتاب‌دهی سخت‌افزاری
  - [ ] کش کردن متاداده و کاور بازی‌ها
  - [ ] سیستم جستجو، فیلتر و دسته‌بندی

- [ ] **فاز ۴: موتور Ghost Launch** ⚪
  - [ ] اجرا مستقیم و پایش پروسه‌ها
  - [ ] ویرایشگر متغیرهای محیطی و پارامترها
  - [ ] ثبت زمان بازی (Playtime) و آمار محلی

---

## 🔨 ساخت از سورس

### پیش‌نیازها

* **کامپایلر با پشتیبانی از C++23:** MSVC v19.38+, GCC 13+, or Clang 17+
* **فریم‌ورک Qt:** نسخه Qt 6.8+ (ماژول‌های `QtQuick`, `QtQml`, `QtSql`)
* **ابزارهای ساخت:** CMake 3.25+ و Ninja

### مراحل ساخت

```bash
# ۱. کلون کردن مخزن پروژه
git clone [https://github.com/VoidOne-App/VoidOne.git](https://github.com/VoidOne-App/VoidOne.git)
cd VoidOne

# ۲. پیکربندی پروژه (مسیر Qt را بر اساس سیستم خود تنظیم کنید)
cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH="C:/Qt/6.8.0/msvc2022_64"

# ۳. کامپایل پروژه
cmake --build build --config Release --parallel

# ۴. اجرای تست‌ها
ctest --test-dir build --output-on-failure
```

---

## 🤝 مشارکت

مشارکت در پروژه همیشه خیرمقدم گفته می‌شود! چه در زمینه بهینه‌سازی هسته C++، بهبود رابط کاربری QML، منطق اسکنرها یا مستندسازی.

۱. پروژه را Fork کنید.
۲. یک شاخه برای ویژگی جدید بسازید (`git checkout -b feature/AmazingFeature`).
۳. تغییرات خود را Commit کنید (`git commit -m 'feat: Add some AmazingFeature'`).
۴. شاخه را Push کنید (`git push origin feature/AmazingFeature`).
۵. یک Pull Request باز کنید.

---

## 📜 مجوز

این پروژه تحت **مجوز MIT** منتشر شده است. برای اطلاعات بیشتر فایل [`LICENSE`](LICENSE) را مطالعه کنید.

<div align="center">

**VoidOne** — *ساخته‌شده برای کارایی. توسعه‌یافته در دنیای آزاد.*

</div>

</div>
