# دليل المعلّم

## ما تحتاجه
- **جهاز لينكس واحد** يعمل كمضيف للمختبر (لابتوب قديم، أو VPS صغير): Docker Engine و Docker Compose v2.
- لتشغيل 4 صناديق: تقدير عملي **2 vCPU و4 GB RAM** كحدّ أدنى مريح (كل صندوق محدود بـ 512 MB و0.5 CPU في `compose.yaml`). هذه أرقام تقديرية، فقس الاستهلاك الفعلي بـ `docker stats`.
- لكل صديق: برنامج SSH (`ssh` موجود في لينكس وماك وويندوز 10+)، و**من الجلسة 6** Docker على جهازه.

## التشغيل
```bash
git clone https://github.com/ah-alkhalaf/Docker-lernen.git && cd Docker-lernen
cp .env.example .env       # اختياري: كلمات مرور ثابتة أو مفاتيح SSH
make up
make passwords             # كلمات المرور المولّدة عشوائيًا
```
يدخل الصديق رقم N عبر: `ssh -p 220N student@عنوان-المضيف` (الأول 2201، الثاني 2202، ...).

## إضافة صديق خامس
انسخ كتلة `box-4` في `compose.yaml` وسمِّها `box-5`، وغيّر **أربعة أشياء**: الاسم، والـ hostname، والمنفذ (`2205`)، واسم الـ volume (وأضفه في قسم `volumes:` أسفل الملف)، ومتغيرات `BOX5_*` في `.env`. ثم `docker compose up -d`.

## الوصول من الإنترنت
**لا تفتح منافذ SSH للصناديق على الإنترنت العام** بكلمات مرور. بدائل أفضل: شبكة خاصة (WireGuard أو Tailscale)، أو الجلسات حضوريًا على الشبكة المحلية. ويمكنك ضبط `BIND_ADDR=127.0.0.1` في `.env` للوصول من الجهاز نفسه فقط.

## الأمان: ماذا يحمي وماذا لا يحمي
- الصناديق **حاويات Docker عادية**، و`root` داخل الحاوية ليس معزولًا بنفس قوة VM. خففنا ذلك بـ `cap_drop: ALL` مع إضافة الحد الأدنى من الصلاحيات، وحدود موارد لكل صندوق، وبلا `--privileged` وبلا `docker.sock`.
- المستخدم `student` يملك `sudo` كاملًا (ضروري لتعلّم المستخدمين والصلاحيات). لذلك **هذا المختبر لأصدقاء تثق بهم**، وليس لغرباء.
- `no-new-privileges` غير مفعّل عمدًا لأنه يكسر `sudo`.
- للعزل الأقوى (وللتدرّب على systemd وDocker داخل الصندوق) انظر [`sysbox.md`](sysbox.md).

## الجدول المقترح
| الأسبوع | الجلسة | المكان |
|---|---|---|
| 1 | [01 أساسيات لينكس](../sessions/01-linux-basics.md) | صندوق |
| 2 | [02 النصوص والأنابيب](../sessions/02-text-and-pipes.md) | صندوق |
| 3 | [03 المستخدمون والصلاحيات](../sessions/03-users-and-permissions.md) | صندوق |
| 4 | [04 العمليات وcron](../sessions/04-processes-and-cron.md) | صندوق |
| 5 | [05 الشبكات والسكربتات](../sessions/05-networking-and-scripts.md) | صندوقان |
| 6 | [06 Docker وCompose](../sessions/06-docker-and-compose-basics.md) | جهاز الصديق |
| 7 | [07 المكدّس وGit وCI](../sessions/07-full-stack-git-ci.md) | جهاز الصديق |
| 8 | [08 Break/Fix](../sessions/08-break-fix.md) | جهاز الصديق |

للمبتدئين تمامًا: لا تتجاوز **جلسة كل أسبوع**، وكرّر الجلسة 2 إذا لزم، فالأنابيب هي ما يميّز من سيكمل.

## صيانة الصناديق
| المهمة | الأمر |
|---|---|
| إعادة ضبط صندوق واحد (يمسح تقدّمه) | `docker compose rm -sf box-1 && docker volume rm docker-lernen-lab_home-box-1 && docker compose up -d box-1` |
| تحديث الصورة بعد تعديل `Dockerfile` أو `lab/` | `docker compose up -d --build` (الصناديق القديمة تحتفظ بملفاتها لأن البيت في volume) |
| تعديل التحديات لصندوق موجود | احذف `~/.lab-initialized` داخله ثم أعد تشغيله (يُنشئ تحديات جديدة) |
| إيقاف كل شيء مع الحفاظ على التقدّم | `make down` |

## استكشاف الأعطال
- **تحذير `REMOTE HOST IDENTIFICATION HAS CHANGED`** بعد إعادة بناء صندوق: مفاتيح SSH للمضيف تتجدد. عند الصديق: `ssh-keygen -R "[HOST]:2201"`.
- **`Operation not permitted` داخل الصندوق:** نقصت صلاحية (capability) بسبب `cap_drop: ALL`. اقرأ الرسالة وأضف الصلاحية المناسبة في `cap_add` ضمن `compose.yaml`.
- **الصندوق لا يبدأ:** `docker compose logs box-1`، وابحث عن آخر سطر قبل التوقف.
- **نسيان كلمة المرور:** `make passwords`، أو حدّدها في `.env` ثم `docker compose up -d --force-recreate box-1`.
- **منفذ 2201 مستخدم:** غيّر المنفذ في `compose.yaml`.

## ما الذي اختُبر فعلًا؟
انظر قسم "ما الذي اختُبر" في [`README.md`](../README.md).
