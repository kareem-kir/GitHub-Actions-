# 🏗️ هيكل المشروع - Project Structure

## 📁 البنية العامة

```
music_project/
├── 📱 user_app/                    # تطبيق المستخدم
├── 🔐 admin_app/                   # تطبيق الأدمن
├── 🔗 shared/                      # الملفات المشتركة
├── 🗄️ supabase/                    # إعدادات قاعدة البيانات
├── 📋 README.md                    # دليل المشروع الكامل
├── ⚡ QUICK_START.md               # دليل البدء السريع
└── 🏗️ PROJECT_STRUCTURE.md        # هذا الملف
```

## 📱 تطبيق المستخدم (user_app/)

```
user_app/
├── lib/
│   ├── 🎯 main.dart                # نقطة البداية
│   ├── core/                       # الملفات الأساسية
│   │   ├── theme/
│   │   │   └── app_theme.dart      # تصميم التطبيق
│   │   └── services/
│   │       ├── audio_service.dart  # خدمة تشغيل الصوت
│   │       └── download_service.dart # خدمة التحميل
│   └── presentation/               # واجهة المستخدم
│       ├── bloc/                   # إدارة الحالة
│       │   ├── auth/
│       │   ├── music/
│       │   └── user/
│       ├── pages/                  # الصفحات
│       │   ├── splash_page.dart
│       │   ├── auth/
│       │   ├── home/
│       │   ├── category/
│       │   ├── player/
│       │   └── subscription/
│       └── widgets/                # المكونات
│           ├── category_card.dart
│           ├── track_tile.dart
│           └── mini_player.dart
├── android/                        # إعدادات Android
├── ios/                           # إعدادات iOS
└── pubspec.yaml                   # تبعيات المشروع
```

## 🔐 تطبيق الأدمن (admin_app/)

```
admin_app/
├── lib/
│   ├── 🎯 main.dart                # نقطة البداية
│   ├── core/
│   │   └── theme/
│   │       └── admin_theme.dart    # تصميم لوحة التحكم
│   └── presentation/
│       ├── bloc/                   # إدارة الحالة
│       │   ├── auth/
│       │   ├── content/
│       │   └── users/
│       ├── pages/                  # صفحات الإدارة
│       │   ├── splash_page.dart
│       │   ├── auth/
│       │   ├── dashboard/
│       │   ├── categories/
│       │   ├── tracks/
│       │   ├── users/
│       │   └── settings/
│       └── widgets/                # مكونات الإدارة
│           ├── admin_drawer.dart
│           └── stats_card.dart
├── android/
├── ios/
└── pubspec.yaml
```

## 🔗 الملفات المشتركة (shared/)

```
shared/
├── models/                         # نماذج البيانات
│   ├── user_model.dart            # نموذج المستخدم
│   ├── category_model.dart        # نموذج القسم
│   └── track_model.dart           # نموذج المقطع الصوتي
└── services/                      # الخدمات المشتركة
    └── supabase_service.dart      # خدمة Supabase
```

## 🗄️ إعدادات قاعدة البيانات (supabase/)

```
supabase/
├── schema.sql                     # هيكل قاعدة البيانات
└── storage.sql                    # إعدادات التخزين
```

## 📊 قاعدة البيانات

### الجداول الرئيسية:

#### 👥 users
```sql
- id (UUID, PK)
- phone (VARCHAR, UNIQUE)
- display_name (VARCHAR)
- status (ENUM: free, weekly, monthly, yearly)
- subscription_expiry (TIMESTAMP)
- downloaded_tracks (TEXT[])
- total_downloads (INTEGER)
```

#### 📂 categories
```sql
- id (UUID, PK)
- name (VARCHAR)
- name_ar (VARCHAR)
- description (TEXT)
- description_ar (TEXT)
- image_url (TEXT)
- is_locked (BOOLEAN)
- required_subscription (ENUM)
- order_index (INTEGER)
- is_active (BOOLEAN)
```

#### 🎵 tracks
```sql
- id (UUID, PK)
- title (VARCHAR)
- title_ar (VARCHAR)
- artist (VARCHAR)
- artist_ar (VARCHAR)
- category_id (UUID, FK)
- audio_url (TEXT)
- image_url (TEXT)
- duration (INTEGER)
- is_locked (BOOLEAN)
- required_subscription (ENUM)
- download_count (INTEGER)
- play_count (INTEGER)
- order_index (INTEGER)
- is_active (BOOLEAN)
```

#### 🔐 admins
```sql
- id (UUID, PK)
- email (VARCHAR, UNIQUE)
- display_name (VARCHAR)
- role (ENUM: super_admin, content_manager, user_manager)
- permissions (TEXT[])
- is_active (BOOLEAN)
```

#### ⚙️ app_settings
```sql
- key (VARCHAR, PK)
- value (JSONB)
- updated_at (TIMESTAMP)
```

## 🗂️ Storage Buckets

### 📁 tracks
- **الغرض**: تخزين الملفات الصوتية
- **الصيغ المدعومة**: MP3, WAV, M4A
- **الحد الأقصى**: 50MB لكل ملف
- **الصلاحيات**: قراءة عامة، كتابة للأدمن فقط

### 🖼️ track-images
- **الغرض**: صور المقاطع الصوتية
- **الصيغ المدعومة**: JPG, PNG, WebP
- **الحد الأقصى**: 5MB لكل ملف
- **الصلاحيات**: قراءة عامة، كتابة للأدمن فقط

### 🖼️ category-images
- **الغرض**: صور الأقسام
- **الصيغ المدعومة**: JPG, PNG, WebP
- **الحد الأقصى**: 5MB لكل ملف
- **الصلاحيات**: قراءة عامة، كتابة للأدمن فقط

## 🔄 تدفق البيانات

### تطبيق المستخدم:
```
User Input → BLoC → Supabase Service → Supabase → Real-time Updates
```

### تطبيق الأدمن:
```
Admin Action → BLoC → Supabase Service → Supabase → Real-time Sync → User App
```

## 🛡️ الأمان والصلاحيات

### Row Level Security (RLS):
- ✅ المستخدمون: الوصول لبياناتهم فقط
- ✅ الأقسام: قراءة للجميع، كتابة للأدمن
- ✅ المقاطع: قراءة للجميع، كتابة للأدمن
- ✅ المديرين: وصول محدود حسب الدور
- ✅ الإعدادات: قراءة للجميع، كتابة للأدمن

### Storage Policies:
- ✅ الملفات الصوتية: قراءة عامة، رفع للأدمن فقط
- ✅ الصور: قراءة عامة، رفع للأدمن فقط

## 📱 المميزات المطبقة

### تطبيق المستخدم:
- ✅ تسجيل الدخول بالهاتف
- ✅ تصفح الأقسام والمقاطع
- ✅ تشغيل الموسيقى مع تحكم كامل
- ✅ تحميل للتشغيل بدون إنترنت
- ✅ نظام الاشتراكات
- ✅ واجهة عصرية مع ثيم داكن
- ✅ دعم اللغة العربية (RTL)
- ✅ مزامنة لحظية

### تطبيق الأدمن:
- ✅ تسجيل دخول آمن
- ✅ لوحة تحكم مع إحصائيات
- ✅ إدارة الأقسام (CRUD)
- ✅ إدارة المقاطع مع رفع الملفات
- ✅ إدارة المستخدمين والاشتراكات
- ✅ البحث المتقدم
- ✅ إعدادات التطبيق
- ✅ نظام صلاحيات

## 🔧 نقاط التخصيص

### الألوان والتصميم:
- `user_app/lib/core/theme/app_theme.dart`
- `admin_app/lib/core/theme/admin_theme.dart`

### النصوص والترجمة:
- النصوص مدمجة في الكود (يمكن تحويلها لنظام ترجمة)

### الإعدادات:
- جدول `app_settings` في قاعدة البيانات

### الصلاحيات:
- ملفات SQL في مجلد `supabase/`

## 📈 التطوير المستقبلي

### مميزات مقترحة:
- [ ] نظام الإشعارات Push
- [ ] قوائم التشغيل المخصصة
- [ ] نظام التقييمات والمراجعات
- [ ] تطبيق ويب للإدارة
- [ ] دعم المزيد من صيغ الملفات
- [ ] نظام التحليلات المتقدم
- [ ] دعم اللغات المتعددة
- [ ] نظام الدفع المتكامل

---

**هذا المشروع جاهز للاستخدام والتطوير!** 🚀
