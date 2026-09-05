<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### پلتفرم متن‌باز و بومی بازی‌های رایانه‌ای؛ ساخته‌شده حول بازی‌های شما، نه فروشگاه‌ها

<p>
  <a href="README.md">🇬🇧 English</a> •
  <b>🇮🇷 پارسی</b>
</p>

<p>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml"><img src="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml/badge.svg" alt="CI/CD" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases/latest"><img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?include_prereleases&label=Latest%20Release" alt="Latest Release" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers"><img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?style=flat" alt="GitHub Stars" /></a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE"><img src="https://img.shields.io/github/license/VoidOne-App/VoidOne" alt="License" /></a>
</p>

<p>
  <b>C++23</b> •
  <b>Qt 6.11.2</b> •
  <b>QML / Qt Quick</b> •
  <b>SQLite</b>
</p>

<p>
  <b>Windows x64 — پلتفرم اصلی</b> •
  <b>MIT License</b>
</p>

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

</div>

---

# 🌌 VoidOne چیست؟

**VoidOne** یک پلتفرم متن‌باز و بومی برای بازی‌های رایانه‌ای است که بر اساس یک اصل ساده در حال توسعه است:

> **بازی‌های شما باید مرکز تجربه‌ی گیمینگ باشند؛ نه فروشگاه‌هایی که آن‌ها را عرضه می‌کنند.**

VoidOne به‌عنوان یک لایه‌ی بومی میان بازیکن، سیستم‌عامل و اکوسیستم گیمینگ طراحی می‌شود.

چشم‌انداز بلندمدت پلتفرم شامل موارد زیر است:

- 🎮 کتابخانه‌ی بازی‌ها
- 🚀 اجرای بازی
- 👻 مدیریت پردازش‌ها
- 🌐 پشتیبانی از چندین ارائه‌دهنده‌ی بازی
- 🧰 مدیریت Mod
- 📊 تحلیل‌های محلی
- 🩺 عیب‌یابی
- 🎨 شخصی‌سازی
- 🧠 هوش مصنوعی انتخاب‌شده توسط کاربر
- 🌍 ترجمه
- 🔌 افزونه‌ها و ابزارهای توسعه‌دهندگان

VoidOne **فروشگاه نیست**؛ هدف آن ایجاد یک لایه‌ی باز، بومی و ماژولار برای مدیریت و تعامل با محیط‌های گیمینگی است که بازیکن از قبل در اختیار دارد.

---

# 🎯 چشم‌انداز

هدف بلندمدت VoidOne این است که کنترل بیشتری روی بازی‌ها، سخت‌افزار، داده‌ها، گردش‌کارها و سیستم‌های هوشمند اختیاری در اختیار بازیکن قرار دهد.

```text
PLAYER
  │
  ▼
VOIDONE
  │
  ├── Game Libraries
  ├── Execution Layer
  ├── Diagnostics
  ├── Local Data
  └── Optional Intelligence
          │
          ├── Local AI
          └── Cloud AI
  │
  ▼
OPERATING SYSTEM
```

هدف مالک‌شدن اکوسیستم بازیکن نیست؛ هدف این است که **رابطی بهتر برای اکوسیستمی که بازیکن همین حالا در اختیار دارد ایجاد شود.**

---

# 🧭 فلسفه‌ی اصلی

## 🧱 Native First

هر زمان که فناوری‌ها و قابلیت‌های بومی مزیت معناداری در عملکرد، یکپارچگی، قابلیت اطمینان، نگهداری و مصرف منابع داشته باشند، در اولویت قرار می‌گیرند.

## 🔒 حریم خصوصی از ابتدا

اطلاعات بازیکن نباید بدون یک دلیل فنی مشروع جمع‌آوری، منتقل یا از آن‌ها درآمدزایی شود.

## 💾 Local First

هر زمان که از نظر فنی امکان‌پذیر باشد، داده‌های مهم بازیکن باید به‌صورت محلی و تحت کنترل خود او باقی بمانند.

## ⚡ طراحی‌شده برای سبک‌بودن

وابستگی‌ها، پردازش‌های پس‌زمینه، Runtimeها و سرویس‌ها باید هزینه‌ی مصرف منابع خود را توجیه کنند.

## 🎮 مالکیت بازیکن

بازیکن باید کنترل بازی‌ها، تنظیمات، پروفایل‌ها، داده‌ها، یکپارچه‌سازی‌ها و سیستم‌های هوش مصنوعی اختیاری را در اختیار داشته باشد.

## 🌐 Open by Design

VoidOne باید قابل بررسی، قابل تغییر، قابل توسعه و در دسترس مشارکت‌کنندگان باقی بماند.

## 🧠 هوش مصنوعی تحت کنترل کاربر

VoidOne قصد ندارد یک مدل هوش مصنوعی اختصاصی را به کاربران تحمیل کند. هوش مصنوعی باید اختیاری، قابل جایگزینی و تحت کنترل کاربر باشد.

## 📐 شواهد، نه بازاریابی

ادعاهای فنی باید بر اساس پیاده‌سازی، تست، Benchmark، مستندات یا شواهد قابل بازتولید پشتیبانی شوند.

---

# 📦 وضعیت فعلی پروژه

VoidOne در مرحله‌ی **توسعه‌ی فعال و آزمایشی** قرار دارد. نسخه‌های فعلی نمایانگر پیاده‌سازی در حال تکامل هستند، نه تمام چشم‌انداز بلندمدت پروژه.

| وضعیت | معنی |
|---|---|
| 🟢 Implemented | در مخزن فعلی پیاده‌سازی شده |
| 🧪 Experimental | پیاده‌سازی شده ولی هنوز در حال اعتبارسنجی است |
| 🛠️ Development | در حال توسعه است |
| 🔭 Planned | بخشی از مسیر آینده‌ی پروژه |
| 🚀 Stable | مخصوص milestoneهای اثبات‌شده و آماده‌ی تولید |

> **وجود یک مورد در Roadmap به معنی پیاده‌سازی‌شدن آن نیست.**

مخزن و تنظیمات CI منابع اصلی برای تشخیص وضعیت فعلی پیاده‌سازی و فرآیند Build هستند.

---

# 🏗️ پایه‌ی فنی فعلی

| فناوری | نقش |
|---|---|
| **C++23** | توسعه‌ی Native و سیستمی |
| **Qt 6.11.2** | Framework برنامه |
| **QML / Qt Quick** | رابط کاربری |
| **SQLite** | ذخیره‌سازی محلی |
| **CMake 3.25+** | پیکربندی Build |
| **Ninja** | اجرای Build |
| **CTest** | تست خودکار |
| **GitHub Actions** | CI/CD |
| **MSVC x64** | Toolchain اصلی Windows |
| **NSIS** | ساخت Installer ویندوز |

Pipeline فعلی Windows بر پایه‌ی Qt 6.11.2، MSVC x64، Ninja، تست‌های خودکار، Qt deployment، NSIS و ساخت Portable ZIP است.

---

# 🧩 معماری

## پایه‌ی فعلی

```text
┌──────────────────────┐
│      Qt / QML UI     │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│  C++ Application     │
│       Layer          │
└──────────┬───────────┘
           ▼
┌──────────────────────┐
│    Native C++ Core   │
└───────┬────────┬─────┘
        │        │
        ▼        ▼
   ┌────────┐  ┌──────────────┐
   │ SQLite │  │ OS APIs      │
   └────────┘  └──────────────┘
```

معماری طوری طراحی شده که برنامه‌ی محلی بتواند بدون نیاز به یک Backend سنگین، قابلیت‌های اصلی خود را ارائه دهد.

---

# 🗺️ نقشه‌ی راه پلتفرم

## Phase I — Native Foundation

- C++23
- Qt / QML
- CMake
- SQLite
- معماری Native
- GitHub Actions CI/CD
- Build و Packaging ویندوز
- تست و Diagnostics خودکار

## Phase II — Library Intelligence

موارد برنامه‌ریزی‌شده:

- کشف بازی‌ها
- تشخیص نصب
- ذخیره‌سازی Library
- هویت بازی
- Indexing
- نرمال‌سازی Metadata
- Provider abstraction

## Phase III — Gaming Experience

موارد برنامه‌ریزی‌شده:

- کتابخانه‌ی پیشرفته
- Search و Filtering
- دسته‌بندی
- Artwork و Metadata
- شخصی‌سازی
- بهبود Dynamic UI

## Phase IV — 👻 Ghost Launcher

یک لایه‌ی اجرای کنترل‌شده میان VoidOne و Process بازی.

قابلیت‌های احتمالی شامل Launch Arguments، Environment Configuration، پروفایل‌های اختصاصی، مدیریت چرخه‌ی Process و Runtime State است.

VoidOne قصد دورزدن DRM، الزامات Licensing یا احراز هویت ضروری پلتفرم‌ها را ندارد.

## Phase V — 🧠 VoidOne Intelligence

معماری بلندمدت هوش مصنوعی برای پشتیبانی از AI محلی و ابری انتخاب‌شده توسط کاربر طراحی می‌شود.

حوزه‌های احتمالی:

- کمک به Game Library
- Diagnostics
- کمک به Configuration
- Translation
- پیشنهادهای Hardware-aware
- کمک Context-aware

هوش مصنوعی اختیاری است و نباید به Dependency اجباری Launcher تبدیل شود.

## فازهای آینده

برنامه‌ریزی بلندمدت همچنین شامل موارد زیر است:

- 🌐 پشتیبانی از چند Provider / Store
- 🧰 Mod Platform
- 🩺 Diagnostics و Local Analytics
- 🎨 Personalization
- 💾 Backup و Recovery
- 🔌 Developer و Extension Ecosystem

این موارد همچنان وابسته به معماری، پیاده‌سازی و اعتبارسنجی هستند.

---

# 🤖 هوش مصنوعی در مهندسی

VoidOne همچنین دارای زیرساخت آزمایشی **AI-assisted development** است. این بخش از معماری هوش مصنوعی سمت کاربر جداست.

هدف این زیرساخت کمک به تشخیص خطاهای CI و تولید Candidate Repair است، در حالی که Validation قطعی و بررسی انسانی کنترل نهایی را حفظ می‌کنند.

```text
CI Failure
    │
    ▼
Failure Analysis
    │
    ▼
AI-Assisted Diagnosis
    │
    ▼
Candidate Repair
    │
    ▼
Build / Tests / Validation
    │
    ▼
Human Review
```

خروجی تولیدشده توسط AI به‌عنوان خروجی غیرقابل اعتماد در نظر گرفته می‌شود و باید از Policyها و Validationهای مخزن عبور کند.

این زیرساخت **به‌صورت خودکار تغییرات را Merge نمی‌کند.**

---

# 🪟 وضعیت پلتفرم‌ها

## Windows — پلتفرم اصلی

Windows در حال حاضر محیط اصلی توسعه، Build، Test و Packaging است.

Pipeline انتشار برای **Windows x64** هدف‌گذاری شده است.

بسته‌های فعلی انتشار:

- `VoidOne-Setup-x64.exe` — Installer با NSIS
- `VoidOne-Portable-x64.zip` — نسخه‌ی Portable

## 🐧 Linux — مسیر Cross-Platform

Linux بخشی از مسیر معماری Cross-Platform پروژه است، اما Pipeline فعلی انتشار، مسیر اصلی Packaging لینوکس نیست.

## 🍎 macOS

macOS در حال حاضر بخشی از Pipeline اصلی Build و Packaging نیست.

---

# 📦 Pipeline انتشار Windows

CI فعلی این مراحل را انجام می‌دهد:

1. نصب Qt 6.11.2
2. پیکربندی MSVC x64
3. Build نسخه‌ی Release با C++23
4. اجرای تست‌های Database و Lifecycle
5. اجرای Full CTest
6. Deploy کردن Runtimeهای Qt
7. ساخت Installer با NSIS
8. Code Signing اختیاری در صورت تنظیم Secrets
9. ساخت Portable ZIP
10. Upload کردن Artifactها

Workflow مخزن مرجع اصلی رفتار CI است و ممکن است مستقل از این README تغییر کند.

---

# 🔨 Build از Source

## نیازمندی‌ها

برای Build اصلی Windows:

- Windows 10/11
- Visual Studio 2022 / MSVC x64
- Qt **6.11.x**
- CMake 3.25+
- Ninja
- Git

Clone:

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

Configure:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23
```

اگر CMake نتوانست Qt را پیدا کند:

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23 -DCMAKE_PREFIX_PATH="C:\Qt\6.11.2\msvc2022_64"
```

Build:

```bash
cmake --build build --parallel
```

Test:

```bash
ctest --test-dir build --output-on-failure
```

برای پیکربندی دقیق CI به `.github/workflows/c.cpp.yml` مراجعه کنید.

---

# 🧪 Testing & Validation

مخزن فعلی شامل Validation خودکار برای بخش‌هایی مانند موارد زیر است:

- رفتار Database
- چرخه‌ی عمر Database
- مدیریت Save Backup
- اجرای CTest
- Qt deployment موردنیاز تست‌ها
- Windows packaging
- بررسی وجود Artifactها

همچنین زیرساخت Validation برای Candidateهای تعمیر تولیدشده توسط AI وجود دارد که شامل Build، Package، Patch و Workflow validation است.

---

# 🔐 امنیت

امنیت در سراسر پروژه یک موضوع مهندسی محسوب می‌شود.

زیرساخت فعلی شامل Compiler hardening، پشتیبانی از Sanitizer در حالت‌های پیکربندی‌شده، Policyهای مخزن برای AI tooling و Permissionهای کنترل‌شده‌ی CI است.

یک پیکربندی CodeQL در مخزن وجود دارد، اما Workflow فعال CI مرجع اصلی برای مشخص‌کردن Checkهایی است که واقعاً اجرا می‌شوند.

VoidOne ادعای Certification امنیتی یا تضمین امنیت مطلق ندارد، مگر اینکه به‌صورت صریح مستند شده باشد.

---

# 🤝 مشارکت

از مشارکت در زمینه‌های زیر استقبال می‌شود:

- C++
- Qt / QML
- UI/UX
- Testing
- Documentation
- Performance
- Build Systems
- CI/CD
- Security
- Developer Tooling
- Platform Support

برای تغییرات مهم، توضیح دهید چه چیزی تغییر کرده، چرا تغییر کرده، چگونه تست شده و چه ملاحظات Compatibility، Performance یا Security دارد.

تغییرات را متمرکز، قابل بررسی و قابل نگهداری نگه دارید.

راهنمای مشارکت در [`CONTRIBUTING.md`](CONTRIBUTING.md) قرار دارد.

---

# 📚 مستندات

مستندات پروژه حوزه‌هایی مانند موارد زیر را پوشش می‌دهند:

- Build و Development
- Architecture
- CI/CD
- Release Engineering
- زیرساخت AI-assisted Repair
- Security
- Translation
- Performance

مخزن منبع اصلی برای پیاده‌سازی فعلی، ابزارهای پشتیبانی‌شده، رفتار CI و تنظیمات Release است.

---

# 🏁 معیارهای Stable

Stable یک milestone مهندسی است، نه صرفاً یک برچسب نسخه.

قبل از Stable، VoidOne قصد دارد موارد زیر را تثبیت کند:

- قابلیت‌های اصلی قابل اتکا
- نصب و Upgrade قابل اتکا
- Runtime Stability
- پوشش تست گسترده‌تر
- Benchmarkهای Performance
- Security Validation
- مستندات کامل Release
- چرخه‌های Release Candidate

> **Stable یک milestone است که با مهندسی به دست می‌آید؛ نه برچسبی که صرفاً بر اساس زمان‌بندی انتخاب شود.**

---

# 📜 License

VoidOne تحت **MIT License** منتشر می‌شود.

متن کامل License در [`LICENSE`](LICENSE) قرار دارد.

---

<div align="center">

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

### ♾️ Free & Open Source
### 🚫 بدون تبلیغات. بدون تله‌متری.
### 🔒 داده‌های شما. کنترل شما.
### 🧠 هوش مصنوعی شما. انتخاب شما.
### 🎮 ساخته‌شده توسط یک گیمر. برای گیمرها.
### 🧪 امروز Experimental. وقتی آماده شد Stable.

**Open Source · Native · Modular · Player-Focused**

[⭐ Star VoidOne](https://github.com/VoidOne-App/VoidOne) ·
[📦 Releases](https://github.com/VoidOne-App/VoidOne/releases) ·
[🐛 Issues](https://github.com/VoidOne-App/VoidOne/issues) ·
[🤝 Contributing](https://github.com/VoidOne-App/VoidOne/blob/main/CONTRIBUTING.md)

**VoidOne یک پروژه‌ی فعال در حال توسعه است.**

**قابلیت‌ها به‌صورت تدریجی و هم‌زمان با تکامل پلتفرم معرفی می‌شوند.**

</div>
