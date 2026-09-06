<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### پلتفرم متن‌باز و بومی بازی‌های رایانه‌ای؛ ساخته‌شده حول بازی‌های شما، نه فروشگاه‌ها

<p><a href="README.md">🇬🇧 English</a> • <b>🇮🇷 پارسی</b></p>

<p><b>C++23</b> • <b>Qt 6.11.2</b> • <b>QML / Qt Quick</b> • <b>SQLite</b> • <b>CMake</b> • <b>Ninja</b></p>

<p><b>Windows x64 — پلتفرم اصلی انتشار</b> • <b>MIT License</b></p>

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

</div>

---

## 🌌 VoidOne چیست؟

**VoidOne** یک پلتفرم متن‌باز و بومی برای بازی‌های رایانه‌ای است که حول یک اصل ساده ساخته می‌شود:

> **بازی‌های شما باید مرکز تجربه‌ی گیمینگ باشند؛ نه فروشگاه‌هایی که آن‌ها را عرضه می‌کنند.**

VoidOne یک لایه‌ی بومی میان بازیکن، سیستم‌عامل و اکوسیستم گیمینگ است. **فروشگاه نیست** و هدفش جایگزین‌کردن سرویس‌هایی که بازی‌های شما را توزیع می‌کنند نیست.

چشم‌انداز بلندمدت شامل موارد زیر است:

- 🎮 کتابخانه و کشف بازی‌ها
- 🚀 اجرای بازی و مدیریت پردازش‌ها
- 🌐 اتصال به چندین ارائه‌دهنده
- 🧰 مدیریت Mod
- 📊 تحلیل و عیب‌یابی محلی
- 🎨 شخصی‌سازی
- 🧠 هوش مصنوعی اختیاری و تحت کنترل کاربر
- 🌍 ترجمه
- 🔌 افزونه‌ها و ابزارهای توسعه‌دهندگان

## 🧭 اصول اصلی

- **Native First** — استفاده از فناوری‌های بومی و قابلیت‌های سیستم‌عامل وقتی باعث بهبود عملکرد، یکپارچگی یا نگهداری شوند.
- **Privacy by Design** — جلوگیری از جمع‌آوری و انتقال غیرضروری داده‌ها.
- **Local First** — کنترل محلی داده‌ها و وضعیت مهم کاربر تا حد امکان.
- **Lightweight by Design** — هر وابستگی و پردازش پس‌زمینه باید هزینه‌ی منابع خود را توجیه کند.
- **Player Ownership** — کنترل بازی‌ها، تنظیمات، داده‌ها، اتصال‌ها و سیستم‌های هوشمند اختیاری در دست کاربر باشد.
- **Open by Design** — پروژه قابل بررسی، تغییر و توسعه باقی بماند.
- **Evidence over Marketing** — ادعاهای فنی باید با پیاده‌سازی، تست، بنچمارک یا شواهد قابل بازتولید پشتیبانی شوند.

## 📦 وضعیت پروژه

VoidOne در مرحله‌ی **توسعه‌ی فعال و آزمایشی** است. مخزن و تنظیمات CI منبع اصلی حقیقت درباره‌ی قابلیت‌های فعلی هستند.

| وضعیت | معنی |
|---|---|
| 🟢 Implemented | در مخزن فعلی پیاده‌سازی شده |
| 🧪 Experimental | پیاده‌سازی شده ولی هنوز در حال اعتبارسنجی |
| 🛠️ Development | در حال توسعه |
| 🔭 Planned | برنامه‌ی آینده |
| 🚀 Stable | فقط برای نقاط عطف اثبات‌شده |

> وجود یک مورد در Roadmap به معنی پیاده‌سازی‌شدن آن نیست.

## 🏗️ پایه‌ی فنی

| فناوری | نقش |
|---|---|
| C++23 | توسعه‌ی Native و سیستم‌ها |
| Qt 6.11.2 | فریم‌ورک برنامه |
| QML / Qt Quick | رابط کاربری |
| SQLite | ذخیره‌سازی محلی |
| CMake 3.25+ | سیستم Build |
| Ninja | اجرای Build |
| CTest | تست خودکار |
| GitHub Actions | CI/CD |
| MSVC x64 | Toolchain اصلی Windows |
| NSIS | ساخت Installer ویندوز |

## 🧩 معماری

```text
┌──────────────────────────────────────────────┐
│                  Qt / QML UI                 │
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│              Application entry               │
│                 src/main.cpp                 │
└──────────────────────┬───────────────────────┘
                       ▼
┌──────────────────────────────────────────────┐
│                Native C++ core               │
│                 src/core/                    │
└───────────────┬───────────────────┬──────────┘
                ▼                   ▼
        ┌──────────────┐    ┌──────────────┐
        │    SQLite    │    │   OS / Qt    │
        │ local state  │    │ integrations │
        └──────────────┘    └──────────────┘
```

جزئیات مرزبندی بخش‌ها در [`docs/architecture/overview.md`](docs/architecture/overview.md) قرار دارد.

## 🗺️ Roadmap

### Phase I — Native Foundation

- پایه‌ی C++23
- پایه‌ی Qt / QML
- سیستم Build با CMake
- ذخیره‌سازی SQLite
- معماری Native
- CI/CD و بسته‌بندی Windows
- تست خودکار و Diagnostics

### Phase II — Library Intelligence

- کشف بازی‌ها
- تشخیص نصب
- ذخیره و Index کتابخانه
- هویت و Metadata بازی
- abstraction برای Providerها

### Phase III — Gaming Experience

- رابط کتابخانه‌ی پیشرفته
- جست‌وجو و فیلتر
- دسته‌بندی
- Artwork و Metadata
- شخصی‌سازی

### Phase IV — 👻 Ghost Launcher

یک لایه‌ی آینده برای مدیریت اجرای بازی، Launch Arguments، پروفایل هر بازی، چرخه‌ی عمر Process و Runtime State.

VoidOne قصد دورزدن DRM، مجوزها یا احراز هویت اجباری پلتفرم‌ها را ندارد.

### Phase V — 🧠 VoidOne Intelligence

یک لایه‌ی هوشمند اختیاری برای مدل‌های محلی و ابری انتخاب‌شده توسط کاربر، با کاربردهایی مثل دستیار کتابخانه، Diagnostics، تنظیمات، ترجمه و گردش‌کارهای سخت‌افزاری.

AI قرار است اختیاری و قابل‌جایگزینی باشد و به وابستگی اجباری Core تبدیل نشود.

## 🤖 Engineering AI

پروژه زیرساخت آزمایشی AI برای تشخیص خطاهای CI و ساخت Candidate Repair نیز دارد. این بخش با VoidOne Intelligence کاربر نهایی متفاوت است.

خروجی AI قابل اعتماد تلقی نمی‌شود و باید از اعتبارسنجی قطعی و بررسی انسانی عبور کند.

راهنما: [`docs/engineering/ai-repair.md`](docs/engineering/ai-repair.md)

## 🪟 انتشار Windows

Windows در حال حاضر پلتفرم اصلی Build، Test و Release است. Pipeline شامل Build، تست، Deploy وابستگی‌های Qt، اعتبارسنجی Installer، NSIS، امضای اختیاری، ZIP قابل‌حمل و انتشار GitHub Release برای Tagها است.

فایل‌های انتشار:

- `VoidOne-Setup-x64.exe`
- `VoidOne-Portable-x64.zip`

راهنمای انتشار: [`docs/release/windows.md`](docs/release/windows.md)

## 🔨 ساخت از Source

مسیر پیشنهادی استفاده از CMake Presetها است:

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
cmake --preset dev
cmake --build --preset dev
ctest --preset dev
```

برای Build بهینه:

```bash
cmake --preset release
cmake --build --preset release
ctest --preset release
```

برای پیکربندی مشابه CI ویندوز:

```bash
cmake --preset ci-windows
cmake --build --preset ci-windows
ctest --preset ci-windows
```

راهنمای کامل: [`docs/build.md`](docs/build.md)

## 📚 مستندات

- [راهنمای Build](docs/build.md)
- [معماری](docs/architecture/overview.md)
- [مهندسی Release ویندوز](docs/release/windows.md)
- [AI-Assisted Repair](docs/engineering/ai-repair.md)
- [Troubleshooting](docs/troubleshooting.md)
- [مشارکت](CONTRIBUTING.md)
- [امنیت](SECURITY.md)

## 🤝 مشارکت

مشارکت در C++، Qt/QML، UI/UX، تست، مستندات، Performance، Build، CI/CD، امنیت، Developer Tooling و پشتیبانی از پلتفرم‌ها استقبال می‌شود.

تغییرات را کوچک، قابل بررسی و قابل نگهداری نگه دارید و برای تغییرات بزرگ، دلیل، روش تست و ملاحظات سازگاری را توضیح دهید.

## 🔐 امنیت

امنیت بخشی از مهندسی پروژه است. برای گزارش مسائل امنیتی طبق [`SECURITY.md`](SECURITY.md) عمل کنید و جزئیات حساس را در Issue عمومی منتشر نکنید.

## 📜 مجوز

VoidOne تحت **MIT License** منتشر می‌شود.

---

<div align="center">

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

♾️ Free & Open Source · 🚫 No Ads · 🔒 Privacy First · 🧠 Optional AI

</div>
