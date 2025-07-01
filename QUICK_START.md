# 🚀 دليل البدء السريع - Quick Start Guide

## ⚡ إعداد سريع في 10 دقائق

### 1. إنشاء مشروع Supabase (3 دقائق)

1. **اذهب إلى** [supabase.com](https://supabase.com)
2. **أنشئ حساب** أو سجل الدخول
3. **أنشئ مشروع جديد**:
   - اختر اسم المشروع: `music-player`
   - اختر كلمة مرور قوية لقاعدة البيانات
   - اختر المنطقة الأقرب لك

### 2. إعداد قاعدة البيانات (2 دقيقة)

1. **اذهب إلى SQL Editor** في لوحة تحكم Supabase
2. **انسخ والصق** محتوى ملف `supabase/schema.sql`
3. **اضغط Run** لتنفيذ الكود
4. **انسخ والصق** محتوى ملف `supabase/storage.sql`
5. **اضغط Run** لتنفيذ الكود

### 3. الحصول على المفاتيح (1 دقيقة)

1. **اذهب إلى Settings > API**
2. **انسخ**:
   - `Project URL`
   - `anon public key`

### 4. تكوين التطبيقات (2 دقيقة)

#### في `user_app/lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co', // ضع الـ URL هنا
  anonKey: 'your-anon-key-here', // ضع المفتاح هنا
);
```

#### في `admin_app/lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'https://your-project-id.supabase.co', // ضع الـ URL هنا
  anonKey: 'your-anon-key-here', // ضع المفتاح هنا
);
```

### 5. تشغيل التطبيقات (2 دقيقة)

```bash
# تطبيق المستخدم
cd user_app
flutter pub get
flutter run

# في terminal آخر - تطبيق الأدمن
cd admin_app
flutter pub get
flutter run
```

## 🔑 بيانات الدخول الافتراضية

### تطبيق الأدمن:
- **البريد الإلكتروني**: `admin@musicplayer.com`
- **كلمة المرور**: ستحتاج لإنشاء مستخدم في Supabase Auth

### إنشاء مدير جديد:
1. اذهب إلى **Authentication > Users** في Supabase
2. أنشئ مستخدم جديد بالبريد الإلكتروني: `admin@musicplayer.com`
3. المستخدم سيظهر تلقائياً في جدول `admins`

## 📱 اختبار التطبيق

### تطبيق المستخدم:
1. **سجل الدخول** برقم هاتف (مثل: +966501234567)
2. **تصفح الأقسام** المتاحة
3. **جرب تشغيل** مقطع صوتي
4. **اختبر التحميل** للتشغيل بدون إنترنت

### تطبيق الأدمن:
1. **سجل الدخول** ببيانات المدير
2. **أضف قسم جديد** مع صورة
3. **ارفع مقطع صوتي** جديد
4. **ابحث عن مستخدم** وعدل اشتراكه
5. **تحقق من الإحصائيات**

## 🎵 إضافة محتوى تجريبي

### إضافة أقسام:
```sql
INSERT INTO categories (name, name_ar, description, description_ar, order_index) VALUES 
('Pop Music', 'موسيقى البوب', 'Popular music tracks', 'مقاطع موسيقى البوب', 1),
('Rock Music', 'موسيقى الروك', 'Rock music collection', 'مجموعة موسيقى الروك', 2);
```

### إضافة مقاطع تجريبية:
يمكنك استخدام ملفات MP3 مجانية من:
- [Pixabay Music](https://pixabay.com/music/)
- [Freesound](https://freesound.org/)
- [YouTube Audio Library](https://www.youtube.com/audiolibrary)

## 🔧 تخصيص سريع

### تغيير رقم الواتساب:
```sql
UPDATE app_settings 
SET value = jsonb_set(value, '{whatsapp_number}', '"+966XXXXXXXXX"')
WHERE key = 'general';
```

### تغيير اسم التطبيق:
```sql
UPDATE app_settings 
SET value = jsonb_set(value, '{app_name}', '"Your App Name"')
WHERE key = 'general';
```

## ❗ مشاكل شائعة وحلولها

### 1. "Target of URI doesn't exist"
**الحل**: تأكد من وجود مجلد `shared` في نفس مستوى مجلدي `user_app` و `admin_app`

### 2. "Supabase URL is required"
**الحل**: تأكد من تعديل الـ URL والمفتاح في ملفات `main.dart`

### 3. "Permission denied"
**الحل**: تأكد من تشغيل ملفات SQL بشكل صحيح

### 4. "Admin not found"
**الحل**: أنشئ مستخدم في Supabase Auth بنفس البريد المدرج في جدول `admins`

## 📞 الحصول على المساعدة

إذا واجهت أي مشكلة:
1. **تحقق من** ملف `README.md` للتفاصيل الكاملة
2. **راجع** رسائل الخطأ في Console
3. **تأكد من** إعدادات Supabase
4. **تحقق من** صلاحيات قاعدة البيانات

---

## 🎉 مبروك!

إذا وصلت هنا، فقد نجحت في إعداد مشروع مشغل الموسيقى بالكامل! 

الآن يمكنك:
- ✅ إدارة المحتوى من تطبيق الأدمن
- ✅ تشغيل الموسيقى من تطبيق المستخدم
- ✅ إدارة الاشتراكات والمستخدمين
- ✅ رفع الملفات الصوتية والصور

**استمتع بتطبيقك الجديد!** 🎵
