# الجلسة 6: Docker وأول ملف Compose

**المدة:** ساعتان · **المكان:** جهازك أنت (أو خادم فيه Docker) ، وليس صندوق المختبر · **المتطلبات:** الجلسات 1–5

> تحتاج Docker على جهازك: لينكس مباشرة، أو Docker Desktop (ويندوز/ماك)، أو WSL2. الأمر `docker run --rm hello-world` يجب أن ينجح قبل بدء الجلسة.

## الهدف
أن يفهم الصديق الفرق بين **صورة** و**حاوية**، ويبني صورة لتطبيق، ويكتب أول `compose.yaml` بيده.

## الفكرة في دقيقتين
- **الصورة (image)**: قالب للقراءة فقط (نظام + برنامج + إعداداته).
- **الحاوية (container)**: نسخة تعمل من الصورة، معزولة عن غيرها، وتُتلف بسهولة.
- **Compose**: ملف واحد يصف **عدة** حاويات وشبكاتها وتخزينها، فتشغّل كل شيء بأمر واحد.
- تذكّر الجلسة 5: الحاويات في Compose تصل لبعضها **بأسماء الخدمات** (كما وصل box-2 إلى box-1).

## ورقة الغش

| الأمر | ماذا يفعل |
|---|---|
| `docker run -d --name web -p 8081:80 nginx:alpine` | شغّل حاوية (المنفذ `مضيف:حاوية`) |
| `docker ps` / `docker ps -a` | الحاويات العاملة / كلها |
| `docker logs -f web` | سجلات الحاوية |
| `docker exec -it web sh` | ادخل إلى حاوية تعمل |
| `docker stop web && docker rm web` | أوقف ثم احذف |
| `docker build -t اسم .` | ابنِ صورة من Dockerfile |
| `docker compose up -d` | شغّل كل الخدمات (`--build` لإعادة البناء) |
| `docker compose ps` / `logs -f` / `down` | الحالة / السجلات / الإيقاف |

## شغّل ثم افهم
1. **أول حاوية:**
   ```bash
   docker run -d --name web -p 8081:80 nginx:alpine
   curl http://localhost:8081
   docker logs web
   docker exec -it web sh      # ls /usr/share/nginx/html ثم exit
   docker stop web && docker rm web
   ```
2. **ابنِ صورة التطبيق** (من مستودع هذا المشروع):
   ```bash
   cd startup/app
   cat Dockerfile                    # اقرأه سطرًا سطرًا
   docker build -t startup-app .
   docker run --rm -p 8000:8000 startup-app
   curl http://localhost:8000/health     # {"db":"memory","status":"ok"}
   ```
   لماذا يعمل التطبيق بلا قاعدة بيانات؟ (ابحث عن `DATABASE_URL` في `app.py`.)

## التحدي: اكتب Compose بنفسك
أنشئ مجلدًا جديدًا `my-stack/` بجوار `startup/` واكتب فيه `compose.yaml` يشغّل:
- خدمة `db` من الصورة `postgres:16-alpine` بكلمة مرور تحددها، **وبـ volume مسمّى** حتى لا تضيع البيانات.
- خدمة `app` تُبنى من `../startup/app`، وتُنشر على المنفذ 8000، ومتغير بيئتها
  `DATABASE_URL=postgresql://postgres:كلمة_المرور@db:5432/postgres`.

هيكل البداية:
```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: ???
    volumes:
      - ???
  app:
    build: ???
    ports: ["8000:8000"]
    environment:
      DATABASE_URL: ???
volumes:
  ???:
```
ثم:
```bash
docker compose up -d --build
curl http://localhost:8000/health        # {"db":"up",...}
curl http://localhost:8000/api/visits    # كرّرها: العدّاد يزيد
docker compose down                      # بدون -v
docker compose up -d
curl http://localhost:8000/api/visits    # هل بقي العدّاد؟ لماذا؟
```
وقد تفشل المحاولة الأولى لأن التطبيق يبدأ قبل جاهزية قاعدة البيانات. هذه مشكلة حقيقية، وحلّها موضوع الجلسة 7.

## أسئلة للنقاش
- ماذا يحدث للبيانات عند `docker compose down` مقابل `docker compose down -v`؟
- لماذا نكتب `@db:5432` وليس `@localhost:5432` في `DATABASE_URL`؟
- ما الفرق بين `ports: "8000:8000"` و`expose`؟

## ملاحظات للمعلّم
- لا تعطِهم الحل الكامل. الجلسة 7 تبدأ بمقارنة حلولهم مع [`startup/compose.yaml`](../startup/compose.yaml).
- الخطأ الشائع: مسافات YAML (استعملوا مسافتين لا Tab)، وكتابة `localhost` بدل اسم الخدمة.
- على ويندوز مع WSL2: الأوامر تعمل من داخل توزيعة WSL، وليس من PowerShell فقط.
