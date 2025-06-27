# 🚀 دليل Git السريع - مشروع Tic Tac Toe

## 📝 **آخر التحديثات**
- ✅ تم إنشاء نقطة حفظ أولى للمشروع الكامل
- ✅ تم إضافة تاجات مهمة للإصدارات
- ✅ المشروع جاهز للتطوير والتوسع
- 🎯 الهدف التالي: إنشاء نقطة "main-app" كنقطة استرجاع أساسية

---

## 🎯 البداية السريعة

### إنشاء مستودع Git أول مرة:
```bash
cd "c:\Users\ibrah\projects\projects for code\tic_tac_toe"
git init
git add .
git commit -m "🎉 Initial commit: Complete Tic Tac Toe project"
```

---

## 🖥️ **استخدام Git من VS Code مباشرة (بدون Terminal)**

### 🚀 **البداية الأولى - إنشاء المستودع:**

#### الخطوة 1: إنشاء مستودع محلي
1. اضغط `Ctrl + Shift + G` (Source Control panel)
2. انقر على **"Initialize Repository"**
3. سيتم إنشاء مستودع Git تلقائياً

#### الخطوة 2: إضافة الملفات وأول commit
1. في Source Control panel، ستجد جميع الملفات تحت "Changes"
2. انقر على **`+`** الكبير لإضافة جميع الملفات
3. في مربع الرسالة أعلى، اكتب: `🎉 Initial commit: Complete Tic Tac Toe project`
4. اضغط `Ctrl + Enter` أو انقر على زر ✓

#### الخطوة 3: ربط بـ GitHub
1. أنشئ مستودع جديد على GitHub.com
2. في VS Code، اضغط `Ctrl + Shift + P`
3. اكتب واختر: **"Git: Add Remote"**
4. أدخل URL المستودع: `https://github.com/yourusername/tic_tac_toe.git`
5. اكتب اسم: `origin`

#### الخطوة 4: الرفع الأول
1. في Source Control panel، انقر **"Publish Branch"**
2. أو انقر على السهم الصاعد بجانب **"Sync Changes"**

### 💾 **حفظ التقدم اليومي من VS Code:**

#### كل مرة تعدل فيها شيء:
1. **`Ctrl + S`** - احفظ الملفات
2. **`Ctrl + Shift + G`** - افتح Source Control
3. **انقر `+`** بجانب الملفات المُعدّلة (أو `+` الكبير للكل)
4. **اكتب رسالة** مثل: `🔧 Fix: حل مشكلة Firebase على Windows`
5. **`Ctrl + Enter`** - عمل commit
6. **انقر "Sync"** أو السهم الصاعد - رفع للخادم

### 📊 **عرض التقدم والتاريخ:**

#### طريقة 1: Timeline
- في Explorer panel (يسار)، انقر على **"Timeline"** أسفل قائمة الملفات
- ستجد تاريخ جميع التغييرات لكل ملف

#### طريقة 2: Git Graph (إضافة مفيدة)
1. `Ctrl + Shift + X` (Extensions)
2. ابحث عن **"Git Graph"**
3. اضغط **Install**
4. بعد التثبيت، ستجد زر "Git Graph" في Source Control panel
5. يعطيك عرض بياني جميل لجميع النقاط

### 🌿 **العمل مع الفروع (Branches):**

#### إنشاء فرع جديد:
1. انقر على اسم الفرع في الشريط السفلي (مثل `main`)
2. اختر **"Create new branch from..."**
3. اكتب اسم الفرع: `feature/store-improvements`
4. اضغط Enter

#### التنقل بين الفروع:
- انقر على اسم الفرع في الشريط السفلي
- اختر الفرع المطلوب من القائمة

#### دمج الفروع:
1. انتقل للفرع الرئيسي (`main`)
2. `Ctrl + Shift + P`
3. اكتب واختر: **"Git: Merge Branch"**
4. اختر الفرع المراد دمجه

### ↩️ **التراجع والاستعادة:**

#### التراجع عن تغييرات غير محفوظة:
- في Source Control، انقر على سهم **"Discard Changes"** بجانب الملف

#### التراجع عن آخر commit:
1. `Ctrl + Shift + P`
2. اكتب واختر: **"Git: Undo Last Commit"**

#### استعادة ملف من نقطة سابقة:
1. في Timeline، انقر على النقطة المرغوبة
2. انقر **"Restore"**

---

## 💡 **سيناريو عملي: من البداية للنهاية**

### إعداد المشروع لأول مرة:
```
1. VS Code → Ctrl + Shift + G
2. انقر "Initialize Repository"
3. إضافة جميع الملفات (+)
4. رسالة: "🎉 مشروع Tic Tac Toe كامل مع جميع الإصلاحات"
5. Ctrl + Enter (commit)
6. إنشاء مستودع على GitHub
7. Ctrl + Shift + P → "Git: Add Remote"
8. إدخال URL المستودع
9. انقر "Publish Branch"
```

### الاستخدام اليومي:
```
1. تعديل الملفات وحفظها (Ctrl + S)
2. Ctrl + Shift + G
3. مراجعة التغييرات
4. إضافة الملفات (+)
5. كتابة رسالة واضحة
6. Ctrl + Enter (commit)
7. انقر "Sync" (رفع للخادم)
```

### إنشاء نقطة مهمة (Tag):
```
1. Ctrl + Shift + P
2. "Git: Create Tag"
3. اسم التاج: v1.0-stable
4. رسالة: "إصدار مستقر - جميع الأخطاء مُصلحة"
5. Ctrl + Shift + P → "Git: Push Tags"
```

---

## 💾 حفظ التقدم اليومي

### الأوامر الأساسية:
```bash
# التحقق من الحالة
git status

# إضافة الملفات
git add .

# حفظ التقدم
git commit -m "🔧 Fix: [وصف الإصلاح]"

# رفع للخادم (بعد ربط GitHub)
git push
```

## 🌿 العمل مع الفروع

### إنشاء فروع للميزات:
```bash
# إنشاء فرع جديد
git checkout -b feature/new-store-items

# التنقل بين الفروع
git checkout main
git checkout feature/new-store-items

# دمج الفرع في الرئيسي
git checkout main
git merge feature/new-store-items
```

## ↩️ التراجع والاستعادة

### أوامر الأمان:
```bash
# التراجع عن آخر commit (مع حفظ التغييرات)
git reset --soft HEAD~1

# استعادة ملف من حالة سابقة
git checkout HEAD~1 -- lib/main.dart

# عرض تاريخ المشروع
git log --oneline
```

## ☁️ GitHub Integration

### ربط المشروع بـ GitHub:
```bash
# إضافة مستودع بعيد
git remote add origin https://github.com/yourusername/tic_tac_toe.git

# رفع للمرة الأولى
git push -u origin main

# الرفع المستمر
git push
```

## 🏷️ إنشاء نقاط مهمة (Tags)

### حفظ إصدارات مستقرة:
```bash
# إنشاء tag للإصدار المستقر
git tag -a v1.0-stable -m "All critical errors fixed"

# رفع التاجات للخادم
git push origin --tags
```

## 🛡️ النسخ الاحتياطية

### حفظ العمل مؤقتاً:
```bash
# حفظ التغييرات مؤقتاً
git stash save "Working on store improvements"

# استعادة العمل
git stash pop

# عرض المحفوظات المؤقتة
git stash list
```

---

## 📋 سيناريوهات العمل المقترحة

### نهاية كل جلسة عمل:
```bash
git add .
git commit -m "🔧 Daily: [وصف ما تم عمله اليوم]"
git push
```

### عند إضافة ميزة جديدة:
```bash
git checkout -b feature/ai-improvements
# ... العمل على الميزة ...
git add .
git commit -m "✨ Feature: Enhanced AI game logic"
git checkout main
git merge feature/ai-improvements
git push
```

### عند إصلاح مشكلة:
```bash
git checkout -b fix/firebase-connection
# ... إصلاح المشكلة ...
git add .
git commit -m "🔧 Fix: Firebase connection issues on Windows"
git checkout main
git merge fix/firebase-connection
git push
```

---

## 🎨 رموز Commit المقترحة

- 🔧 `:wrench:` - إصلاحات
- ✨ `:sparkles:` - ميزات جديدة  
- 🎨 `:art:` - تحسينات التصميم
- 📚 `:books:` - توثيق
- 🧪 `:test_tube:` - اختبارات
- 🚀 `:rocket:` - نشر
- 🐛 `:bug:` - إصلاح أخطاء
- 🔥 `:fire:` - حذف كود

---

**💡 نصيحة:** احفظ هذا الملف كمرجع سريع واستخدم الأوامر حسب الحاجة!
