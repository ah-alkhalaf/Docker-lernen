# Docker-lernen 🐳

مختبر عملي لتعليم **لينكس والشبكات وDocker Compose ومنهجية DevOps** لأصدقاء مبتدئين، عبر مشروع واحد يكبر من جلسة إلى أخرى: **شركة ناشئة وهمية**.

كل صديق يحصل على "خادم لينكس" خاص به (حاوية يدخلها عبر SSH)، يتعلم فيه الأساسيات بتحديات يتحقق منها سكربت تلقائيًا. ثم ينقل خبرته إلى بناء مكدّس حقيقي (Caddy + تطبيق + PostgreSQL) بـ Docker Compose، مع Git وCI وفحوص صحة ومراقبة، وينتهي بجلسة **إصلاح أنظمة معطّلة**.

## تشغيل سريع (للمعلّم)

```bash
git clone https://github.com/ah-alkhalaf/Docker-lernen.git && cd Docker-lernen
make up            # يبني ويشغّل 4 صناديق
make passwords     # كلمات المرور المولّدة
```
ثم يدخل الصديق: `ssh -p 2201 student@عنوان-المضيف`، وبعد أي تحدٍّ يكتب `lab-check N` ليعرف هل نجح.
التفاصيل الكاملة في [دليل المعلّم](docs/teacher-guide.md).

## الجلسات

| # | الموضوع | تحقق تلقائي |
|---|---|---|
| 1 | [أساسيات لينكس: SSH والتنقل والملفات](sessions/01-linux-basics.md) | `lab-check 1` |
| 2 | [النصوص والأنابيب: grep وawk وfind](sessions/02-text-and-pipes.md) | `lab-check 2` |
| 3 | [المستخدمون والمجموعات والصلاحيات](sessions/03-users-and-permissions.md) | `lab-check 3` |
| 4 | [العمليات والإشارات وcron](sessions/04-processes-and-cron.md) | `lab-check 4` |
| 5 | [الشبكات وسكربتات bash](sessions/05-networking-and-scripts.md) | `lab-check 5` |
| 6 | [Docker وأول ملف Compose](sessions/06-docker-and-compose-basics.md) | يدوي |
| 7 | [المكدّس الكامل وGit وCI/CD والمراقبة](sessions/07-full-stack-git-ci.md) | `startup/verify.sh` |
| 8 | [أصلح النظام المعطّل](sessions/08-break-fix.md) | `startup/verify.sh` |

الجلسات 1–5 داخل صناديق المختبر. الجلسات 6–8 على جهاز الصديق (يحتاج Docker).

## هيكل المستودع

```
Docker-lernen/
├── Dockerfile              صورة صندوق المختبر (Ubuntu 24.04 + sshd + أدوات)
├── compose.yaml            4 صناديق على شبكة labnet
├── .env.example            كلمات مرور ومفاتيح SSH (اختياري)
├── Makefile                up / down / passwords / reset / test
├── lab/                    سكربتات الصندوق: التحديات و lab-check
├── sessions/               الجلسات الثماني (بالعربية)
├── startup/                "الشركة الناشئة": تطبيق Flask + Compose + Caddy
│   ├── app/                  التطبيق واختباراته وDockerfile
│   ├── compose.yaml          المكدّس الكامل
│   ├── verify.sh             فحص آلي للمكدّس
│   └── break-fix/            سيناريوهات الأعطال وحلولها
├── docs/                   دليل المعلّم وملاحظة Sysbox
└── .github/workflows/      CI
```

## الأمان باختصار
صناديق المختبر حاويات عادية والمستخدم فيها يملك `sudo`، لذا **للأصدقاء الموثوقين فقط ولا تعرّضها للإنترنت العام**. التفاصيل وخيارات العزل الأقوى في [دليل المعلّم](docs/teacher-guide.md).

## ما الذي اختُبر وما لم يُختبر

أُعدّ المستودع في بيئة **بلا Docker**، لذلك:

**اختُبر فعليًا:**
- سكربتات التحقق `lab-check` 1 و2 و3 و5 بالحلول الصحيحة والخاطئة، وتوليد ملفات التحديات.
- تطبيق Flask: 4 اختبارات وحدة ناجحة، وتشغيله بـ gunicorn (نفس أمر الحاوية).
- صحة كل ملفات YAML (Compose وسيناريوهات Break/Fix) وأن تعديل كل سيناريو مطبَّق، و`shellcheck` نظيف على كل السكربتات.

**لم يُختبر بعد (سيكشفه أول تشغيل):**
- **بناء صورة المختبر وتشغيلها**، وخصوصًا قائمة الصلاحيات `cap_add` (قد تحتاج إضافة صلاحية).
- `lab-check 4` (العمليات وcron) داخل الصندوق الحقيقي.
- تشغيل `startup/compose.yaml` الكامل، وسيناريوهات Break/Fix (نصوص الأعراض قد تختلف حسب إصدار Docker).
- **CI على GitHub**: فيه خطوة تبني الصورة وتشغّلها وتجرّب `sudo useradd`. وهي فحص ذاتي مفيد عند أول `push`، فإن فشلت فالسجل يدلّك على الصلاحية الناقصة.

## الترخيص
لم يُحدَّد بعد. اختر ترخيصًا مناسبًا (مثل MIT) وأضف ملف `LICENSE` قبل مشاركة المستودع علنًا.
