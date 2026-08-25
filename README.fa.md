<div align="center">

<img src="https://raw.githubusercontent.com/VoidOne-App/VoidOne/main/.github/assets/banner.png" alt="VoidOne Banner" width="100%" />

# 🌌 VoidOne

### پلتفرم متن‌باز و بومی بازی‌های رایانه‌ای؛ ساخته‌شده حول بازی‌های شما، نه فروشگاه‌ها

<p>
  <b>🇬🇧 English</b> •
  <a href="README.fa.md">🇮🇷 پارسی</a>
</p>

<p>
  <a href="https://github.com/VoidOne-App/VoidOne/actions/workflows/c.cpp.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/VoidOne-App/VoidOne/c.cpp.yml?label=CI%2FCD" alt="CI/CD">
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/releases/latest">
    <img src="https://img.shields.io/github/v/release/VoidOne-App/VoidOne?label=Latest%20Release" alt="Latest Release">
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/stargazers">
    <img src="https://img.shields.io/github/stars/VoidOne-App/VoidOne?label=GitHub%20Stars" alt="GitHub Stars">
  </a>
  <a href="https://github.com/VoidOne-App/VoidOne/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/VoidOne-App/VoidOne?label=License" alt="License">
  </a>
</p>

<p>
  <b>C++23</b> •
  <b>Qt 6.8</b> •
  <b>QML / Qt Quick</b> •
  <b>SQLite</b>
</p>

<p>
  <b>Windows and Linux</b> •
  <b>MIT License</b>
</p>

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

</div>

---

# 🌌 VoidOne چیست؟

**VoidOne** یک پلتفرم متن‌باز و بومی برای بازی‌های رایانه‌ای است که بر اساس یک اصل ساده در حال توسعه است:

> **بازی‌های شما باید مرکز تجربه‌ی گیمینگ باشند؛ نه فروشگاه‌هایی که آن‌ها را عرضه می‌کنند.**

امروزه تجربه‌ی گیمینگ روی PC میان فروشگاه‌ها، لانچرها، مسیرهای نصب، Manifestها، سیستم‌های پیکربندی، سرویس‌های متادیتا، سرویس‌های پس‌زمینه و فایل‌های اجرایی مستقل بازی‌ها پراکنده شده است.

VoidOne در حال ساخته‌شدن به‌عنوان یک **لایه‌ی بومی میان بازیکن، سیستم‌عامل و اکوسیستم گیمینگ** است.

چشم‌انداز بلندمدت پلتفرم این است که به‌مرور بخش‌های مختلف این اکوسیستم را در یک محیط یکپارچه کنار هم قرار دهد:

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

VoidOne **فروشگاه نیست**.

هدف آن جایگزین‌کردن تمام اکوسیستم‌های فعلی گیمینگ با یک اکوسیستم بسته‌ی دیگر نیست.

در عوض، VoidOne می‌خواهد یک **لایه‌ی باز، بومی و ماژولار** در اختیار بازیکن قرار دهد تا بتواند بازی‌ها و محیط‌های گیمینگ فعلی خود را از طریق آن مدیریت و با آن‌ها تعامل کند.

---

# 🎯 چشم‌انداز

چشم‌انداز بلندمدت VoidOne این است که به یک پلتفرم قدرتمند بومی برای گیمینگ تبدیل شود؛ پلتفرمی که کنترل بیشتری روی بازی‌ها، سخت‌افزار، داده‌ها، گردش‌کارها و سیستم‌های هوشمند اختیاری در اختیار بازیکن قرار می‌دهد.

```text
                           ┌──────────────────────┐
                           │        PLAYER        │
                           └──────────┬───────────┘
                                      │
                                      ▼
                           ┌──────────────────────┐
                           │       VOIDONE        │
                           │                      │
                           │   Native Platform    │
                           └──────────┬───────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         ▼                         ▼
       GAME LIBRARIES          EXECUTION LAYER            INTELLIGENCE
            │                         │                         │
            │                         │                 ┌───────┴───────┐
            │                         │                 │               │
            ▼                         ▼                 ▼               ▼
       PROVIDERS              GAME PROCESSES        LOCAL AI       CLOUD AI
            │                         │                 │               │
            └─────────────────────────┼─────────────────┴───────────────┘
                                      │
                                      ▼
                           ┌──────────────────────┐
                           │   OPERATING SYSTEM   │
                           └──────────────────────┘
```

هدف VoidOne مالک‌شدن اکوسیستم بازیکن نیست.

هدف این است که **رابطی بهتر برای اکوسیستمی که بازیکن همین حالا در اختیار دارد ایجاد کند.**

---

# 🧭 فلسفه‌ی اصلی

VoidOne بر پایه‌ی مجموعه‌ای از اصول مهندسی و محصول در حال توسعه است.

## 🧱 Native First

هر زمان که فناوری‌ها و قابلیت‌های بومی مزیت معناداری در زمینه‌های زیر داشته باشند، استفاده از آن‌ها در اولویت قرار می‌گیرد:

- عملکرد
- یکپارچگی
- قابلیت اطمینان
- قابلیت نگهداری
- مصرف بهینه‌ی منابع

## 🔒 حریم خصوصی از ابتدا

اطلاعات بازیکن نباید بدون یک دلیل فنی مشروع جمع‌آوری، منتقل یا از آن‌ها درآمدزایی شود.

## 💾 Local First

هر زمان که از نظر فنی امکان‌پذیر باشد، داده‌های مهم بازیکن باید به‌صورت محلی و تحت کنترل خود او باقی بمانند.

## ⚡ طراحی‌شده برای سبک‌بودن

هر وابستگی، پردازش پس‌زمینه، Runtime و سرویس باید هزینه‌ی مصرف منابع خود را توجیه کند.

## 🎮 مالکیت بازیکن

بازیکن باید کنترل موارد زیر را در اختیار داشته باشد:

- بازی‌ها
- تنظیمات
- پروفایل‌ها
- داده‌ها
- یکپارچه‌سازی‌ها
- سیستم‌های هوش مصنوعی اختیاری

## 🌐 Open by Design

VoidOne باید:

- قابل بررسی
- قابل تغییر
- قابل توسعه
- در دسترس مشارکت‌کنندگان

باقی بماند.

## 🧠 هوش مصنوعی تحت کنترل کاربر

VoidOne قصد ندارد یک مدل هوش مصنوعی اختصاصی را به کاربران تحمیل کند.

کاربر باید بتواند تصمیم بگیرد:

- اصلاً از هوش مصنوعی استفاده کند یا نه
- از کدام مدل استفاده کند
- مدل کجا اجرا شود
- به کدام ارائه‌دهنده اعتماد کند
- هوش مصنوعی به چه قابلیت‌هایی دسترسی داشته باشد

## 📐 شواهد، نه بازاریابی

ادعاهای فنی باید بر اساس موارد زیر پشتیبانی شوند:

- پیاده‌سازی
- تست
- Benchmark
- مستندات
- شواهد قابل بازتولید

## 🧩 مهندسی تدریجی

VoidOne عمداً به‌صورت مرحله‌ای توسعه داده می‌شود.

قابلیت‌های بزرگ پلتفرم به‌مرور و هم‌زمان با بلوغ معماری زیربنایی آن اضافه خواهند شد.

---

# 🛡️ تعهد Gamer-to-Gamer

VoidOne **توسط یک گیمر و برای گیمرها** ساخته می‌شود.

هدف پروژه ساخت نرم‌افزاری است که به افرادی که از آن استفاده می‌کنند احترام بگذارد.

## ♾️ Free & Open Source

VoidOne متعهد است که **رایگان و متن‌باز** باقی بماند.

هسته‌ی پروژه تحت **MIT License** منتشر می‌شود.

برای استفاده از هسته‌ی پلتفرم اشتراک اجباری وجود ندارد.

قابلیت‌های بنیادی برنامه پشت Paywall قرار نخواهند گرفت.

هدف ایجاد یک اکوسیستم بسته برای قفل‌کردن بازیکنان درون آن نیست.

> **رایگان و متن‌باز بودن یک تعهد اصلی VoidOne است.**

## 🚫 بدون تبلیغات. بدون تله‌متری.

VoidOne بر پایه‌ی تبلیغات یا ردیابی رفتاری ساخته نمی‌شود.

اصل پروژه ساده است:

> **شما از VoidOne برای مدیریت بازی‌هایتان استفاده می‌کنید؛ شما محصول نیستید.**

## 🔒 داده‌های شما. کنترل شما.

VoidOne از رویکرد Local First پیروی می‌کند.

اطلاعات مهمی مانند:

- اطلاعات کتابخانه‌ی بازی
- پروفایل‌ها
- تنظیمات
- آمار محلی
- تنظیمات اختصاصی بازی‌ها
- پروفایل‌های Mod
- پیکربندی‌ها

هر زمان که از نظر فنی امکان‌پذیر باشد، باید تحت کنترل بازیکن باقی بمانند.

## 🎮 ساخته‌شده برای گیمرها

VoidOne برای احترام به موارد زیر ساخته می‌شود:

- سخت‌افزار شما
- حریم خصوصی شما
- زمان شما
- داده‌های شما
- بازی‌های شما
- آزادی شما

> **هدف کنترل بازیکن نیست؛ هدف دادن کنترل بیشتر به بازیکن است.**

---

# 📦 وضعیت پروژه

VoidOne در حال حاضر در وضعیت **توسعه‌ی فعال و آزمایشی** قرار دارد.

پلتفرم به‌صورت تدریجی توسعه پیدا می‌کند.

انتشارهای فعلی نباید نماینده‌ی نسخه‌ی کامل چشم‌انداز بلندمدت پروژه در نظر گرفته شوند.

| وضعیت | معنی |
|---|---|
| 🟢 پیاده‌سازی‌شده | در حال حاضر در مخزن پروژه پیاده‌سازی شده است |
| 🧪 آزمایشی | پیاده‌سازی شده، اما هنوز تحت اعتبارسنجی فعال است |
| 🛠️ در حال توسعه | به‌صورت فعال در حال توسعه است |
| 🔭 برنامه‌ریزی‌شده | بخشی از مسیر موردنظر پلتفرم است |
| 🚀 پایدار | برای نقاط عطف اثبات‌شده و آماده‌ی استفاده‌ی Production رزرو شده است |

> **وجود یک مورد در Roadmap به معنی وجود آن قابلیت در پروژه نیست.**

مخزن پروژه مرجع اصلی برای وضعیت فعلی پیاده‌سازی است.

---

# 🏗️ زیربنای فنی فعلی

VoidOne با استفاده از فناوری‌های مدرن بومی ساخته می‌شود.

| فناوری | نقش |
|---|---|
| **C++23** | توسعه‌ی بومی برنامه و سیستم |
| **Qt 6.8** | چارچوب برنامه |
| **QML / Qt Quick** | رابط کاربری |
| **SQLite** | ذخیره‌سازی محلی |
| **CMake** | پیکربندی سیستم Build |
| **Ninja** | اجرای Build |
| **CTest** | تست خودکار در بخش‌های پیکربندی‌شده |
| **GitHub Actions** | اتوماسیون CI/CD |

معماری فعلی عمداً بر پایه‌ی یک برنامه‌ی بومی بنا شده تا بتواند بدون نیاز به یک Backend سنگین برای عملیات اصلی محلی، رشد کند.

---

# 🧩 معماری پلتفرم

## پایه‌ی فعلی

```text
┌──────────────────────┐
│      Qt / QML UI     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  C++ Application     │
│       Layer          │
└──────────┬───────────┘
           │
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

## معماری بلندمدت پلتفرم

```text
                              ┌──────────────┐
                              │    PLAYER    │
                              └──────┬───────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │  VOIDONE UI  │
                              └──────┬───────┘
                                     │
                                     ▼
                         ┌────────────────────────┐
                         │  APPLICATION PLATFORM  │
                         └───────────┬────────────┘
                                     │
           ┌──────────────┬──────────┼───────────┬──────────────┐
           │              │          │           │              │
           ▼              ▼          ▼           ▼              ▼
       LIBRARY        EXECUTION  MOD PLATFORM ANALYTICS    INTELLIGENCE
           │              │          │           │              │
           ▼              ▼          ▼           ▼              ▼
       PROVIDERS         OS APIs   GAME FILES   LOCAL DB      AI GATEWAY
                                                                    │
                                                        ┌───────────┴───────────┐
                                                        │                       │
                                                        ▼                       ▼
                                                   USER LOCAL AI          USER CLOUD AI
```

معماری بلندمدت به این معنی نیست که همه‌ی این اجزا در حال حاضر وجود دارند.

---

# 🗺️ Roadmap پلتفرم

VoidOne عمداً به‌صورت تدریجی توسعه پیدا می‌کند.

## Phase I — زیرساخت بومی

- پایه‌ی C++23
- پایه‌ی برنامه‌ی Qt / QML
- سیستم Build با CMake
- معماری بومی برنامه
- ذخیره‌سازی SQLite
- CI/CD با GitHub Actions
- اتوماسیون با تمرکز بر امنیت
- Pipeline بسته‌بندی Windows

## Phase II — هوشمندی کتابخانه

حوزه‌های برنامه‌ریزی‌شده:

- کشف بازی‌ها
- تشخیص نصب‌ها
- ذخیره‌سازی کتابخانه
- شناسایی بازی
- ایندکس‌گذاری کتابخانه
- نرمال‌سازی Metadata
- انتزاع Providerها

## Phase III — تجربه‌ی گیمینگ

حوزه‌های برنامه‌ریزی‌شده:

- کتابخانه‌ی پیشرفته‌ی بازی
- جست‌وجو
- فیلتر
- دسته‌بندی
- Artwork
- Metadata
- شخصی‌سازی
- رابط کاربری پویا
- تجربه‌ی QML بهبودیافته

# Phase IV — 👻 Ghost Launcher

**لایه‌ی اجرای بازی.**

Ghost Launcher به‌عنوان یک معماری کنترل‌شده بین VoidOne و پردازش بازی برنامه‌ریزی شده است.

قابلیت‌های احتمالی شامل:

- اجرای مستقیم فایل اجرایی، هر جا که از نظر فنی و قانونی امکان‌پذیر باشد
- آرگومان‌های سفارشی اجرا
- پیکربندی محیط اجرا
- پروفایل‌های اجرای اختصاصی برای هر بازی
- مدیریت چرخه‌ی حیات پردازش
- ردیابی وضعیت Runtime
- سیاست‌های مربوط به پردازش‌های پس‌زمینه
- تشخیص پردازش‌های بدون والد
- اولویت‌بندی پردازش‌ها

از نظر مفهومی:

```text
Player
  │
  ▼
VoidOne
  │
  ▼
Ghost Launcher
  │
  ▼
Execution Layer
  │
  ▼
Game Process
```

هدف:

> **یک لایه‌ی کنترل‌شده‌ی اجرا بین بازیکن و پردازش بازی.**

VoidOne قصد دورزدن DRM، الزامات Licensing یا احراز هویت موردنیاز پلتفرم‌ها را ندارد.

# Phase V — 🧠 VoidOne Intelligence

این فاز معماری **یکپارچه‌سازی هوش مصنوعی** در VoidOne را معرفی می‌کند.

این معماری با قراردادن یک سرویس هوش مصنوعی اختصاصی داخل لانچر تفاوت اساسی دارد.

## هوش مصنوعی تحت کنترل کاربر

VoidOne قرار است **لایه‌ی یکپارچه‌سازی** را فراهم کند و انتخاب سیستم هوش مصنوعی را به کاربر بسپارد.

> **VoidOne پلتفرم را فراهم می‌کند؛ کاربر هوش را انتخاب می‌کند.**

کاربر می‌تواند انتخاب کند:

- Local AI
- Cloud AI
- مدل‌های مختلف
- Providerهای مختلف
- Runtimeهای مختلف
- یا اصلاً بدون AI

### بدون AI اجباری

VoidOne باید بدون AI نیز کاملاً قابل استفاده باقی بماند.

AI یک قابلیت اختیاری پلتفرم است.

هوش مصنوعی نباید به یک وابستگی اجباری برای هسته‌ی لانچر تبدیل شود.

## 🖥️ Local AI

کاربرانی که AI محلی می‌خواهند می‌توانند Runtimeهای خود را متصل کنند، از جمله:

- مدل‌های Open-Weight
- Runtimeهای محلی
- Model Serverها
- شتاب‌دهی سخت‌افزاری
- زیرساخت اختصاصی AI

نقش VoidOne فراهم‌کردن یک Integration استاندارد است، نه تحمیل یک مدل خاص.

```text
User
  │
  ▼
VoidOne
  │
  ▼
AI Gateway
  │
  ▼
Local Runtime
  │
  ▼
User-Selected Model
```

مدل **تحت کنترل کاربر** باقی می‌ماند.

## ☁️ Cloud AI

کاربرانی که سخت‌افزارشان برای Inference محلی مناسب نیست، می‌توانند به‌صورت اختیاری از یک Provider ابری استفاده کنند.

```text
User
  │
  ▼
VoidOne
  │
  ▼
AI Gateway
  │
  ▼
User-Selected Cloud Provider
  │
  ▼
AI Model
```

Cloud AI باید:

- اختیاری
- مستقل از Provider
- کنترل‌شده با Permission
- قابل جایگزینی
- شفاف برای کاربر

باشد.

VoidOne نباید کاربران را مجبور به استفاده از یک Provider اختصاصی AI کند.

## 🔌 AI Gateway

AI Gateway برای جداکردن Providerهای هوش مصنوعی از سایر بخش‌های برنامه طراحی شده است.

```text
                    VoidOne
                       │
                  AI Gateway
                       │
             ┌─────────┴─────────┐
             │                   │
           Local                Cloud
             │                   │
       User Runtime       User Provider
             │                   │
             └─────────┬─────────┘
                       │
                  AI Response
                       │
                       ▼
                VoidOne Context
```

این لایه باعث می‌شود سایر بخش‌های VoidOne بتوانند بدون وابستگی شدید به یک مدل یا Provider خاص، از قابلیت‌های AI استفاده کنند.

# 🧠 AI در سراسر VoidOne

هدف ساخت یک پنجره‌ی Chat جداگانه نیست.

هدف بلندمدت این است که لایه‌ی AI در بخش‌های مختلف پلتفرم، هر جا که واقعاً ارزش ایجاد می‌کند، در دسترس باشد.

## 🎮 Game Library

- جست‌وجوی هوشمند
- سازمان‌دهی بازی‌ها
- کمک به Metadata
- تحلیل کتابخانه

## 👻 Ghost Launcher

- عیب‌یابی اجرا
- تحلیل Runtime
- کمک به پیکربندی
- عیب‌یابی پردازش‌ها

## 🧰 Mod Platform

- کمک درباره‌ی اطلاعات Mod
- تحلیل سازگاری
- تشخیص تداخل‌ها
- پشتیبانی از پیکربندی

## 🩺 Diagnostics

- تحلیل Log
- تفسیر خطا
- تشخیص خرابی
- تحلیل عملکرد

## 🌍 Translation

- ترجمه‌ی متن بازی
- ترجمه‌ی Metadata
- ترجمه‌ی UI
- Workflowهای ترجمه‌ی جامعه

## ⚙️ Configuration

- کمک در پیکربندی
- پیشنهادهای آگاه از سخت‌افزار
- عیب‌یابی
- کمک در راه‌اندازی

قابلیت‌های دقیق به معماری زیربنایی و میزان اعتبارسنجی آن‌ها بستگی خواهند داشت.

# 🌍 Translation Engine

ترجمه به‌عنوان یکی از قابلیت‌های مبتنی بر AI در VoidOne Intelligence برنامه‌ریزی شده است.

کاربردهای احتمالی:

- Metadata بازی
- متن بازی
- متن UI
- ترجمه‌های جامعه
- Workflowهای ترجمه‌ی محلی

معماری باید از هر دو حالت پشتیبانی کند:

```text
Local Translation
        │
        └── User's Local AI

Cloud Translation
        │
        └── User's Selected Provider
```

VoidOne نیازی ندارد مالک مدل ترجمه باشد.

# 🧠 Context Engine

یک Context Engine در آینده ممکن است به VoidOne اجازه دهد اطلاعات مرتبط با وضعیت برنامه را در اختیار سیستم AI قرار دهد.

منابع احتمالی Context:

- بازی فعلی
- پیکربندی بازی
- وضعیت اجرا
- اطلاعات Diagnostics
- تنظیمات انتخاب‌شده توسط کاربر
- Logهای محلی
- پیکربندی Mod
- Metadata کتابخانه

دسترسی به Context باید:

- صریح
- کنترل‌شده با Permission
- حداقلی
- مرتبط
- قابل بررسی

باشد.

> **AI باید Context موردنیاز خود را دریافت کند؛ نه دسترسی نامحدود به همه‌چیز.**

# 🖥️ هوش آگاه از سخت‌افزار

VoidOne ممکن است در آینده قابلیت‌های سخت‌افزاری مرتبط را شناسایی کند، از جمله:

- CPU
- GPU
- RAM
- VRAM
- Storage
- شتاب‌دهی موجود
- Runtimeهای AI محلی

این قابلیت می‌تواند به VoidOne کمک کند تا به کاربر نشان دهد:

- آیا Local Inference عملی است
- کدام مدل مناسب‌تر است
- آیا Cloud Inference گزینه‌ی بهتری است

اما:

> **پیشنهاد به معنی اجبار نیست.**

کنترل همچنان در اختیار کاربر باقی می‌ماند.

# 🔐 AI Permissions

Integrationهای AI باید پشت مرزهای دسترسی مشخص عمل کنند.

| Permission | کاربرد |
|---|---|
| Library Access | خواندن اطلاعات کتابخانه‌ی بازی |
| Metadata Access | خواندن Metadata |
| Configuration Access | خواندن پیکربندی انتخاب‌شده |
| Diagnostics Access | خواندن اطلاعات Diagnostics |
| File Access | دسترسی به فایل‌هایی که صراحتاً مجاز شده‌اند |
| Process Information | خواندن اطلاعات Runtime انتخاب‌شده |
| Network Access | ارتباط با Provider ابری |

هدف این است که یک Integration هوش مصنوعی نتواند به‌صورت خودکار به دسترسی نامحدود به سیستم کاربر دست پیدا کند.

# Phase VI — 🌐 Multi-Store Platform

Providerهای احتمالی برنامه‌ریزی‌شده ممکن است شامل موارد زیر باشند:

- Steam
- Epic Games
- GOG
- EA App
- نصب‌های محلی
- Providerهای بیشتر

قابلیت‌های احتمالی:

- کشف نصب‌ها
- پردازش Manifest
- تجمیع Library
- تشخیص بازی‌های تکراری
- نرمال‌سازی هویت بازی
- اجرای Provider-Aware

هدف یکپارچه‌کردن دسترسی است، بدون اینکه VoidOne به یک Store دیگر تبدیل شود.

# Phase VII — 🧰 Mod Platform

قابلیت‌های برنامه‌ریزی‌شده:

- Mod Profile
- Virtual File Mapping
- استقرار غیرمخرب
- مدیریت Dependency
- تشخیص Conflict
- مدیریت Load Order
- مدیریت Compatibility

مثال:

```text
Game
 ├── Vanilla
 ├── Competitive
 ├── Graphics Overhaul
 ├── Experimental
 └── Custom Profile
```

هدف پشتیبانی از چندین پیکربندی بازی بدون تغییر غیرضروری نصب اصلی است.

# Phase VIII — 🩺 Diagnostics & Analytics

قابلیت‌های احتمالی:

- تحلیل Startup
- Runtime Diagnostics
- اندازه‌گیری عملکرد
- Memory Diagnostics
- Process Analysis
- ثبت Crashهای محلی
- تاریخچه‌ی عملکرد
- Local Gaming Analytics
- AI-Assisted Diagnostics

Analytics باید هر زمان که از نظر فنی امکان‌پذیر است، محلی باقی بماند.

> **تحلیل مفید، بدون تبدیل‌کردن بازیکن به محصول.**

# Phase IX — 🎨 Personalization

قابلیت‌های برنامه‌ریزی‌شده:

- Dynamic Themes
- شخصی‌سازی پیشرفته
- رابط‌های مبتنی بر Artwork
- RGB Customization
- بهبود Accessibility
- Display Scaling
- Responsive Layouts
- Animationهای اختیاری

افکت‌های بصری باید ارزش هزینه‌ی عملکردی خود را داشته باشند.

> **یک رابط کاربری حرفه‌ای فقط زمانی ارزشمند است که همچنان سریع و پاسخ‌گو باقی بماند.**

# Phase X — 💾 Backup & Recovery

قابلیت‌های احتمالی:

- پشتیبان‌گیری از تنظیمات برنامه
- پشتیبان‌گیری از Library
- پشتیبان‌گیری از Game Profile
- پشتیبان‌گیری از Mod Profile
- پشتیبان‌گیری از تنظیمات کاربر
- Import / Export
- Recovery Snapshot
- بازیابی Configuration

# Phase XI — 🔌 Developer Ecosystem

قابلیت‌های توسعه‌ای بلندمدت ممکن است شامل موارد زیر باشند:

- Extension API
- Provider API
- Theme SDK
- Community Extensions
- Custom Integrations
- Developer Tooling
- مرزهای امنیتی Extensionها

امنیت، پایداری و قابلیت نگهداری برای هر سیستم Extension یک الزام باقی می‌مانند.

---

# ⚡ Performance Engineering

عملکرد یکی از اهداف اصلی مهندسی VoidOne است.

موارد زیر **اهداف مهندسی بلندمدت** هستند و مشخصات تضمین‌شده‌ی نسخه‌های فعلی محسوب نمی‌شوند.

| معیار | هدف مهندسی |
|---|---:|
| Idle Memory | `< 50 MB` |
| Cold Startup | `< 1.0s` |
| Database Operations | هدف زیر میلی‌ثانیه |
| UI Rendering | هدف 60+ FPS |
| Library Scanning | حداقل UI Blocking |

این اهداف باید پیش از تبدیل‌شدن به مشخصات رسمی، با Benchmarkهای قابل‌تکرار اعتبارسنجی شوند.

گزارش Benchmark باید موارد زیر را مشخص کند:

- Hardware
- Operating System
- Compiler
- Qt Version
- Application Version
- Build Configuration
- Test Methodology
- شرایط اندازه‌گیری

> **هدف وعده‌دادن عملکرد نیست؛ هدف اثبات آن است.**

---

# 🛡️ Security Engineering

امنیت در سراسر فرایند توسعه به‌عنوان یک مسئله‌ی مهندسی در نظر گرفته می‌شود.

زیرساخت مهندسی فعلی ممکن است شامل موارد زیر باشد:

- GitHub CodeQL
- Cppcheck
- Compiler Hardening
- Sanitizer Validation
- Automated Build Checks
- Artifact Integrity Validation
- SHA-256 Checksums

Buildهای Release در Windows ممکن است از گزینه‌های Hardening زیر استفاده کنند:

```text
/NXCOMPAT
/DYNAMICBASE
/GUARD:CF
/HIGHENTROPYVA
```

مسیر بلندمدت امنیت شامل موارد زیر است:

- Dependency Auditing
- Artifact Integrity Verification
- Reproducible Builds
- Hardened Update Mechanisms
- Secure Extension Boundaries
- Runtime Integrity Validation
- AI Permission Boundaries

VoidOne تا زمانی که به‌صورت صریح مستند نشده باشد، ادعای داشتن گواهی امنیتی یا تضمین امنیت مطلق ندارد.

---

# 🤖 Engineering Automation

VoidOne برای کاهش کارهای تکراری مهندسی و افزایش قابلیت اطمینان توسعه از Automation استفاده می‌کند.

این سیستم‌ها بخشی از **زیرساخت توسعه** هستند و قابلیت‌های کاربرمحور VoidOne محسوب نمی‌شوند.

## 🔄 CI/CD

زیرساخت GitHub Actions ممکن است موارد زیر را پوشش دهد:

- Build Validation
- Static Analysis
- CodeQL
- Cppcheck
- Sanitizer Validation
- Testing
- Release Builds
- Qt Deployment
- Windows Packaging
- Portable ZIP Generation
- SHA-256 Checksum Generation
- Release Automation
- Scheduled Health Checks

Workflowهای مخزن، مرجع اصلی برای رفتار دقیق CI هستند.

---

# 🤖 Autonomous AI CI Repair

VoidOne همچنین دارای یک **Pipeline آزمایشی تعمیر مهندسی با کمک هوش مصنوعی** است.

این سیستم از **VoidOne Intelligence** جداست.

### Engineering AI

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
Build
    │
    ▼
Tests
    │
    ▼
Static / Security Checks
    │
    ▼
Draft Pull Request
    │
    ▼
Human Review
    │
    ▼
Merge
```

موتور تعمیر ممکن است از موارد زیر استفاده کند:

- Local AI Runtimes
- Coding Models
- Cloud AI Providers
- Build Logs
- C++ Tooling
- Qt Tooling
- Automated Validation

تغییرات تولیدشده توسط AI همچنان مشمول موارد زیر هستند:

- Build Validation
- Automated Testing
- Security Checks
- Repository Policy
- Human Review

> **AI مهندسی را سریع‌تر می‌کند؛ اما جایگزین مسئولیت مهندسی نمی‌شود.**

---

# 📦 Release Channels

VoidOne از کانال‌های انتشار تدریجی استفاده می‌کند.

## 🛠️ Development

**وضعیت: فعال**

آخرین وضعیت توسعه‌ی مخزن.

مناسب برای:

- Contributors
- Developers
- Advanced Testers
- CI Validation

## 🧪 Experimental

**وضعیت: در دسترس**

Buildهای Experimental برای موارد زیر در نظر گرفته شده‌اند:

- Early Adopters
- Contributors
- Developers
- Testers
- Feedback
- Feature Validation

این Buildها ممکن است شامل موارد زیر باشند:

- Bug
- قابلیت‌های ناقص
- تغییرات معماری
- اجزای ناتمام

## 🚀 Stable

**وضعیت: به‌زودی**

کانال Stable تنها زمانی معرفی می‌شود که پروژه به سطح مناسبی از موارد زیر برسد:

- Reliability
- Core Functionality
- Test Coverage
- Runtime Stability
- Installation Stability
- Upgrade Reliability
- Performance Validation
- Security Validation
- Documentation Quality

> **Stable یعنی اثبات‌شده؛ نه صرفاً منتشرشده.**

---

# 📦 Release Integrity

هر زمان که SHA-256 Checksum همراه یک Release Artifact منتشر شود، کاربران می‌توانند فایل دانلودشده را به‌صورت محلی بررسی کنند.

### PowerShell

```powershell
Get-FileHash .\VoidOne-Windows-x64-Portable-<version>.zip -Algorithm SHA256
```

Hash تولیدشده را با Checksum منتشرشده در کنار همان Artifact مقایسه کنید.

---

# 🪟 Platform Status

## Windows

**Primary Platform**

Windows در حال حاضر محیط اصلی توسعه، Build و Packaging VoidOne است.

Release Pipeline، Windows x64 را هدف قرار می‌دهد.

## 🐧 Linux

**Cross-Platform Direction**

Linux بخشی از معماری و مسیر توسعه‌ی Cross-Platform VoidOne است.

پشتیبانی از Linux با بالغ‌ترشدن پلتفرم به‌مرور گسترش خواهد یافت.

## 🍎 macOS

macOS در حال حاضر بخشی از Pipeline اصلی Build و Packaging نیست.

---

# 🧰 Technology Stack

| فناوری | نقش |
|---|---|
| **C++23** | توسعه‌ی بومی برنامه و سیستم |
| **Qt 6.8** | چارچوب برنامه |
| **QML / Qt Quick** | رابط کاربری |
| **SQLite** | ذخیره‌سازی محلی |
| **CMake** | پیکربندی Build |
| **Ninja** | اجرای Build |
| **CTest** | Testing |
| **GitHub Actions** | CI/CD |
| **CodeQL** | Security Analysis |
| **Cppcheck** | Static Analysis |
| **AddressSanitizer** | Runtime Diagnostics |
| **MSVC** | Windows C++ Toolchain |
| **NSIS** | Windows Installer Generation |
| **WiX Toolset** | Windows MSI Packaging |

ابزارهای AI مورد استفاده در زیرساخت توسعه ممکن است شامل سیستم‌های محلی و ابری باشند.

این ابزارهای مهندسی از معماری AI کاربرمحور VoidOne جدا هستند.

---

# 🔨 Build From Source

VoidOne در درجه‌ی اول برای Windows توسعه داده و بسته‌بندی می‌شود.

نیازمندی‌های Build ممکن است با پیشرفت پروژه تغییر کنند.

## 🪟 Windows

محیط پیشنهادی:

- Windows 10 / Windows 11
- Visual Studio 2022 / MSVC
- Qt 6.8
- CMake
- Ninja
- Git

Windows Release Pipeline در حال حاضر از موارد زیر استفاده می‌کند:

- Qt 6.8
- MSVC x64
- Ninja
- NSIS
- WiX Toolset

## 🐧 Linux

محیط توسعه‌ی احتمالی:

- یک توزیع جدید Linux
- GCC یا Clang
- Qt 6
- CMake
- Ninja
- Git
- کتابخانه‌های توسعه‌ی سیستمی موردنیاز

---

# 📥 Clone

```bash
git clone https://github.com/VoidOne-App/VoidOne.git
cd VoidOne
```

# ⚙️ Configure

## Windows

اگر Qt توسط CMake قابل شناسایی باشد:

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23
```

اگر CMake نتواند Qt را به‌صورت خودکار پیدا کند:

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="C:\Qt\6.8.0\msvc2022_64"
```

مسیر Qt را متناسب با محل نصب خود تغییر دهید.

## Linux

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23
```

# 🔨 Build

```bash
cmake --build build --parallel
```

# 🧪 Test

اگر Targetهای CTest در دسترس باشند:

```bash
ctest \
  --test-dir build \
  --output-on-failure
```

# 🔍 Static Analysis

اگر `clang-tidy` در دسترس باشد:

```bash
cmake \
  -S . \
  -B build-analysis \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_CLANG_TIDY=clang-tidy
```

سپس:

```bash
cmake --build build-analysis --parallel
```

پیکربندی CI همچنان مرجع اصلی تحلیل خودکار است.

---

# 📦 Windows Packaging

Release Pipeline از Windows Packaging با **NSIS** و **WiX Toolset** در بخش‌هایی که Definitionهای مربوطه پیکربندی شده‌اند، پشتیبانی می‌کند.

فرایند Release ممکن است این مراحل را انجام دهد:

1. Build برنامه
2. Deployment Runtimeهای موردنیاز Qt
3. اعتبارسنجی فایل‌های Deployment
4. ساخت Portable ZIP
5. تولید SHA-256 Checksums
6. ساخت Installer Artifacts
7. انتشار Release Artifacts

برای Deployment محلی Qt:

```bash
windeployqt \
  --release \
  --compiler-runtime \
  --no-translations \
  --qmldir ".\src" \
  ".\path\to\VoidOne.exe"
```

مسیر فایل اجرایی به پیکربندی فعلی Build بستگی دارد.

---

# 🧪 Testing & Validation

Testing بخشی از چرخه‌ی مهندسی VoidOne است.

بسته به پیکربندی مخزن، Validation ممکن است شامل موارد زیر باشد:

- CTest
- Debug Builds
- Release Builds
- AddressSanitizer
- Static Analysis
- CodeQL
- Cppcheck
- QML Validation
- Packaging Validation
- Artifact Validation

Contributors باید پیش از بازکردن Pull Request، Validation مرتبط با تغییرات خود را به‌صورت محلی اجرا کنند.

---

# 📏 Performance Policy

VoidOne ادعاهای مربوط به Performance را ادعاهای مهندسی در نظر می‌گیرد.

پروژه یک عدد آرمانی را Benchmark محسوب نمی‌کند.

اندازه‌گیری‌های احتمالی شامل:

- Cold Startup
- Warm Startup
- Idle Memory
- Peak Memory
- Library Scan Duration
- Database Performance
- CPU Utilization
- UI Frame Time
- تأثیر Background Workload
- تأثیر AI Runtime

پیش از تبدیل‌شدن یک هدف به مشخصات رسمی، Benchmarkها باید موارد زیر را ثبت کنند:

- Hardware
- Operating System
- Compiler
- Qt Version
- Application Version
- Build Configuration
- Methodology
- شرایط اندازه‌گیری

---

# 🤝 Contributing

از مشارکت استقبال می‌شود.

حوزه‌های مشارکت شامل:

- C++
- Qt / QML
- UI/UX
- Testing
- Documentation
- Bug Reports
- Feature Proposals
- Performance
- Platform Support
- Build Systems
- CI/CD
- Security
- Developer Tooling

## Contribution Workflow

یک Feature Branch ایجاد کنید:

```bash
git checkout main
git pull origin main
git checkout -b feature/your-feature
```

تغییرات خود را انجام دهید و آن‌ها را به‌صورت محلی Validate کنید.

سپس:

```bash
git add .
git commit -m "Add your feature"
git push origin feature/your-feature
```

یک Pull Request در GitHub باز کنید.

برای تغییرات مهم، موارد زیر را توضیح دهید:

- چه چیزی تغییر کرده است
- چرا تغییر کرده است
- چگونه تست شده است
- ملاحظات Compatibility
- پیامدهای Performance
- ملاحظات Security

تغییرات را متمرکز، قابل بررسی و قابل نگهداری نگه دارید.

---

# 📐 Engineering Standards

## شواهد، نه بازاریابی

ادعاهای فنی باید با موارد زیر پشتیبانی شوند:

- Implementation
- Tests
- Benchmarks
- Documentation
- Reproducible Evidence

## تغییرات کوچک و قابل بررسی

تغییراتی را ترجیح دهید که متمرکز و به‌راحتی قابل درک باشند.

## Native First

هر زمان که فناوری‌های بومی مزیت فنی معناداری ارائه می‌دهند، استفاده از آن‌ها در اولویت باشد.

## Security by Default

امنیت باید از همان مراحل معماری و پیاده‌سازی در نظر گرفته شود.

## Human-Controlled Automation

Automation و AI می‌توانند به مهندسی کمک کنند، اما انسان‌ها مسئول تصمیم‌های نهایی باقی می‌مانند.

## User-Controlled AI

بازیکن باید کنترل کند:

- آیا از AI استفاده شود
- از کدام AI استفاده شود
- AI کجا اجرا شود
- AI به چه چیزهایی دسترسی داشته باشد

## Long-Term Maintainability

VoidOne برای رشد طی سال‌های آینده طراحی شده است.

بنابراین معماری باید موارد زیر را در اولویت قرار دهد:

- مرزهای مشخص
- ماژولار بودن
- قابلیت تست
- قابلیت توسعه
- قابلیت نگهداری

## احترام به بازیکن

هر قابلیت باید در نهایت به این سؤال پاسخ دهد:

> **آیا این قابلیت بدون گرفتن چیزی غیرضروری از بازیکن، ارزش و کنترل بیشتری در اختیار او قرار می‌دهد؟**

---

# 🐛 Reporting Problems

هنگام گزارش یک مشکل Build یا Runtime، موارد زیر را ارائه دهید:

- سیستم‌عامل
- Compiler
- نسخه‌ی Compiler
- نسخه‌ی Qt
- نسخه‌ی CMake
- Build Configuration
- پیام خطای مرتبط
- مراحل بازتولید

برای مشکلات Runtime، خروجی Terminal یا Debug موجود را نیز ارائه دهید.

گزارش‌های دقیق، بازتولید و رفع مشکلات را بسیار ساده‌تر می‌کنند.

---

# 📚 Documentation

با رشد VoidOne، مستندات بیشتری ممکن است حوزه‌های زیر را پوشش دهند:

- Architecture
- Development
- Build Systems
- CI/CD
- Release Engineering
- AI Architecture
- AI Integrations
- Translation
- Security
- Extension APIs
- Theme Development
- Provider Integrations
- Mod Architecture
- Performance Benchmarking

مخزن پروژه مرجع اصلی برای موارد زیر باقی می‌ماند:

- پیاده‌سازی فعلی
- Build Configuration
- CI Workflows
- Release Configuration
- ابزارهای پشتیبانی‌شده
- نیازمندی‌های توسعه

موارد موجود در Roadmap نباید به‌عنوان مدرکی برای پیاده‌سازی فعلی یک قابلیت در نظر گرفته شوند.

---

# 🏁 Stable Release Criteria

Stable یک نقطه‌ی عطف مهندسی مستقل است.

پیش از Stable، VoidOne قصد دارد موارد زیر را به سطح مناسبی برساند:

- خط پایه‌ی قابلیت‌های Core
- نصب قابل اعتماد
- Upgrade قابل اعتماد
- Runtime Stability
- پوشش گسترده‌تر Automated Testing
- Performance Benchmarking
- Security Validation
- تکمیل Documentation
- Release Candidate Cycle
- Stable Release Criteria
- اولین Stable Release

> **Stable نقطه‌ای است که با مهندسی به دست می‌آید؛ نه برچسبی که صرفاً بر اساس زمان‌بندی روی یک نسخه گذاشته شود.**

---

# 📜 License

VoidOne تحت **MIT License** منتشر می‌شود.

برای متن کامل مجوز به فایل `LICENSE` مراجعه کنید.

---

<div align="center">

# 🌌 VoidOne

### **بازی‌های شما. سخت‌افزار شما. هوش مصنوعی شما. قوانین شما.**

**ساخته‌شده توسط یک گیمر. مهندسی‌شده مثل یک پلتفرم. توسعه‌یافته در فضای باز.**

### ♾️ Free & Open Source

### 🚫 No Ads. No Telemetry.

### 🔒 Your Data. Your Control.

### 🧠 Your AI. Your Choice.

### 🎮 Built by a Gamer. For Gamers.

### 🧪 Experimental Today. Stable When It's Ready.

**Open Source · Native · Modular · Player-Focused**

[⭐ Star VoidOne](https://github.com/VoidOne-App/VoidOne) ·
[📦 Releases](https://github.com/VoidOne-App/VoidOne/releases) ·
[🐛 Issues](https://github.com/VoidOne-App/VoidOne/issues) ·
[🤝 Contributing](https://github.com/VoidOne-App/VoidOne/blob/main/CONTRIBUTING.md)

**VoidOne یک پروژه‌ی فعال در حال توسعه است.**

**قابلیت‌ها به‌صورت تدریجی و هم‌زمان با تکامل پلتفرم معرفی می‌شوند.**

</div>