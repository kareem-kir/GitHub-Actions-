# 🎵 مشغل الموسيقى - Music Player

مشروع متكامل لتطبيق مشغل موسيقى احترافي مع لوحة تحكم إدارية، مبني باستخدام Flutter و Supabase.

## 📱 المشروع يتكون من:

### 1. تطبيق المستخدم (User App)
- مشغل موسيقى احترافي مع واجهة عصرية
- دعم التشغيل بدون إنترنت (Offline)
- نظام اشتراكات متدرج (مجاني، أسبوعي، شهري، سنوي)
- تحميل المقاطع الصوتية محلياً
- مزامنة لحظية مع قاعدة البيانات

### 2. تطبيق الأدمن (Admin App)
- لوحة تحكم شاملة لإدارة المحتوى
- إدارة الأقسام والمقاطع الصوتية
- إدارة المستخدمين والاشتراكات
- رفع الملفات الصوتية والصور
- إحصائيات وتحليلات

## 🛠️ التقنيات المستخدمة

- **Frontend**: Flutter 3.x
- **Backend**: Supabase (PostgreSQL + Real-time + Storage + Auth)
- **State Management**: BLoC Pattern
- **Audio**: just_audio, audio_service
- **UI**: Material Design 3 مع دعم RTL
- **Storage**: Supabase Storage للملفات الصوتية والصور

## 🚀 إعداد المشروع

### 1. متطلبات النظام
```bash
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- حساب Supabase
```

### 2. إعداد Supabase

#### أ. إنشاء مشروع جديد
1. اذهب إلى [supabase.com](https://supabase.com)
2. أنشئ حساب جديد أو سجل الدخول
3. أنشئ مشروع جديد

#### ب. إعداد قاعدة البيانات
1. في لوحة تحكم Supabase، اذهب إلى SQL Editor
2. انسخ محتوى ملف `supabase/schema.sql` وشغله
3. انسخ محتوى ملف `supabase/storage.sql` وشغله

#### ج. الحصول على مفاتيح API
1. اذهب إلى Settings > API
2. انسخ:
   - Project URL
   - anon public key

### 3. إعداد التطبيقات

#### أ. تطبيق المستخدم
```bash
cd user_app
flutter pub get
```

#### ب. تطبيق الأدمن
```bash
cd admin_app
flutter pub get
```

### 4. تكوين المفاتيح

#### في `user_app/lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

#### في `admin_app/lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

#### في `shared/services/supabase_service.dart`:
```dart
static Future<void> initialize() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
}
```

## 🏃‍♂️ تشغيل المشروع

### تطبيق المستخدم
```bash
cd user_app
flutter run
```

### تطبيق الأدمن
```bash
cd admin_app
flutter run
```

## 📊 هيكل قاعدة البيانات

### الجداول الرئيسية:

#### `users` - المستخدمين
- `id` (UUID) - معرف المستخدم
- `phone` (VARCHAR) - رقم الهاتف
- `display_name` (VARCHAR) - اسم المستخدم
- `status` (ENUM) - حالة الاشتراك
- `subscription_expiry` (TIMESTAMP) - تاريخ انتهاء الاشتراك

#### `categories` - الأقسام
- `id` (UUID) - معرف القسم
- `name` / `name_ar` (VARCHAR) - اسم القسم
- `is_locked` (BOOLEAN) - هل القسم مقفول
- `required_subscription` (ENUM) - نوع الاشتراك المطلوب

#### `tracks` - المقاطع الصوتية
- `id` (UUID) - معرف المقطع
- `title` / `title_ar` (VARCHAR) - عنوان المقطع
- `audio_url` (TEXT) - رابط الملف الصوتي
- `category_id` (UUID) - معرف القسم

#### `admins` - المديرين
- `id` (UUID) - معرف المدير
- `email` (VARCHAR) - البريد الإلكتروني
- `role` (ENUM) - دور المدير

## 🔐 نظام الصلاحيات

### المستخدمين:
- قراءة بياناتهم الشخصية فقط
- قراءة الأقسام والمقاطع المتاحة
- تحديث بياناتهم الشخصية

### المديرين:
- إدارة كاملة للأقسام والمقاطع
- إدارة المستخدمين والاشتراكات
- رفع وحذف الملفات
- الوصول للإحصائيات

## 📱 مميزات التطبيق

### تطبيق المستخدم:
- ✅ واجهة عصرية مع ثيم داكن
- ✅ تشغيل الموسيقى مع تحكم كامل
- ✅ تحميل المقاطع للتشغيل بدون إنترنت
- ✅ نظام اشتراكات متدرج
- ✅ مزامنة لحظية للبيانات
- ✅ دعم اللغة العربية (RTL)

### تطبيق الأدمن:
- ✅ لوحة تحكم شاملة
- ✅ إدارة الأقسام مع الصور
- ✅ رفع المقاطع الصوتية
- ✅ إدارة المستخدمين والاشتراكات
- ✅ إحصائيات وتحليلات
- ✅ نظام صلاحيات متقدم

## 🔧 التخصيص

### تغيير رقم الواتساب:
في قاعدة البيانات، جدول `app_settings`:
```sql
UPDATE app_settings 
SET value = jsonb_set(value, '{whatsapp_number}', '"+966XXXXXXXXX"')
WHERE key = 'general';
```

### إضافة مدير جديد:
```sql
INSERT INTO admins (email, display_name, role, is_active) 
VALUES ('admin@example.com', 'Admin Name', 'super_admin', true);
```

## 🐛 استكشاف الأخطاء

### مشاكل شائعة:

#### 1. خطأ في الاتصال بـ Supabase
- تأكد من صحة URL و API Key
- تحقق من إعدادات الشبكة

#### 2. مشاكل الصلاحيات
- تأكد من تشغيل ملفات SQL بشكل صحيح
- تحقق من وجود المدير في جدول `admins`

#### 3. مشاكل رفع الملفات
- تأكد من إعداد Storage buckets
- تحقق من صلاحيات Storage

## 📞 الدعم

للحصول على الدعم أو الإبلاغ عن مشاكل:
- أنشئ Issue في GitHub
- تواصل عبر البريد الإلكتروني

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

---

## 🎯 الخطوات التالية

- [ ] إضافة نظام الإشعارات
- [ ] تطبيق ويب للإدارة
- [ ] دعم المزيد من صيغ الملفات الصوتية
- [ ] نظام التقييمات والمراجعات
- [ ] قوائم التشغيل المخصصة

---

**تم تطوير هذا المشروع بواسطة Augment Agent** 🤖
