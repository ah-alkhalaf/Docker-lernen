# الجلسة 7: المكدّس الكامل وGit وCI/CD والمراقبة

**المدة:** ساعتان ونصف · **المكان:** جهازك (Docker) · **المتطلبات:** الجلسة 6

## الهدف
أن يشغّل الصديق مكدّسًا واقعيًا (وكيل عكسي + تطبيق + قاعدة بيانات) بشبكات منفصلة وفحوص صحة، ثم يضعه في Git مع **تكامل مستمر**، ويراقبه.

## الجزء 1: قارن حلّك بالحل الجاهز (20 دقيقة)
افتح [`startup/compose.yaml`](../startup/compose.yaml) وقارنه بما كتبته في الجلسة 6. ماذا أضاف؟
- `healthcheck` لكل من `db` و`app`، و`depends_on: condition: service_healthy`، أي **انتظر حتى تكون الخدمة جاهزة لا مجرد "بدأت"**.
- شبكتان: `frontend` و`backend`. قاعدة البيانات في `backend` فقط.
- متغيرات في `.env` بدل كتابة كلمة المرور في الملف.
- `caddy` كوكيل عكسي أمام التطبيق، وهو الوحيد المنشور على المضيف.

## الجزء 2: شغّله (30 دقيقة)
```bash
cd startup
cp .env.example .env          # غيّر POSTGRES_PASSWORD
docker compose up -d --build
docker compose ps             # انتظر healthy
./verify.sh                   # فحص آلي
# افتح http://localhost:8080
```
**تجارب لفهم ما حدث:**
```bash
docker compose exec caddy ping -c 1 app     # يعمل: نفس الشبكة frontend
docker compose exec caddy ping -c 1 db      # يفشل! قاعدة البيانات معزولة عن caddy
docker compose stop db
docker compose ps                            # app صار unhealthy بعد قليل
docker compose start db
```
**نسخ احتياطي واستعادة:**
```bash
docker compose exec -T db pg_dump -U startup startup > backup.sql
docker compose exec -T db psql -U startup startup -c "DROP TABLE visits;"
docker compose exec -T db psql -U startup startup < backup.sql
```
(`backup.sql` يحوي بياناتك، فلا تضعه في Git.)

## الجزء 3: Git (30 دقيقة)
1. انسخ مجلد `startup/` إلى مجلد جديد باسم شركتك وأنشئ فيه مستودعًا: `git init && git add . && git commit -m "first commit"`.
2. أنشئ مستودعًا على GitHub وادفع إليه (`git remote add origin ... && git push -u origin main`).
3. تأكد أن `.env` **غير** مرفوع (ملف `.gitignore` يمنعه). كلمات المرور لا تدخل Git أبدًا.
4. اعمل فرعًا لميزة جديدة: `git switch -c feature/new-page` ثم عدّل `app.py` وادمج عبر Pull Request.

## الجزء 4: التكامل المستمر CI (30 دقيقة)
CI = كل `push` يشغّل اختباراتك تلقائيًا. أنشئ `.github/workflows/ci.yml` في مستودعك:
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -r app/requirements-dev.txt
      - run: pytest -q
        working-directory: app
      - run: cp .env.example .env && docker compose build
```
اكسر اختبارًا عمدًا (غيّر `"memory"` في `tests/test_app.py`) وادفع، وشاهد علامة ❌ الحمراء في GitHub، ثم أصلحه وشاهد ✅.
للمثال الأكبر انظر [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) في هذا المستودع.

## الجزء 5: النشر CD والمراقبة (20 دقيقة)
- **CD** معناه أن الكود الذي نجح في CI يصل للخادم تلقائيًا. الفكرة الأبسط: على الخادم سكربت `deploy.sh` يفعل:
  ```bash
  git pull && docker compose up -d --build && ./verify.sh
  ```
  **اكتبه بنفسك** بمهارات الجلسة 5 (رموز الخروج، `set -e`). ثم ناقشوا: كيف يُشغَّل تلقائيًا بعد `push`؟ (Webhook، أو GitHub Actions عبر SSH، أو أدوات مثل ArgoCD). لن نبنيه اليوم.
- **المراقبة:**
  ```bash
  docker compose --profile monitoring up -d
  # افتح http://localhost:3001 وأنشئ حسابًا
  # أضف Monitor من نوع HTTP على:  http://caddy/health
  docker compose stop app     # شاهد التنبيه!
  ```

## أسئلة للنقاش
- ما الفرق بين `restart: unless-stopped` و`healthcheck`؟ (الأول يعيد الحاوية إن ماتت، والثاني يكتشف أنها "حيّة لكن لا تعمل".)
- لماذا لا ننشر منفذ قاعدة البيانات على المضيف؟
- ما الذي يمنعك من دفع كود مكسور للإنتاج؟ (CI ومراجعة الكود والبيئات)

## ملاحظات للمعلّم
- أطول جلسة: يمكن فصل Git/CI في جلسة مستقلة.
- Uptime Kuma يطلب إنشاء حساب في أول فتح، وهذا طبيعي.
- أصدقاء بلا حساب GitHub: جهّز لهم الحساب قبل الجلسة.
