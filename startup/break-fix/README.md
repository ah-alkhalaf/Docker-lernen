# سيناريوهات Break/Fix

أربعة أنظمة معطّلة، لكل منها خطأ واحد مدسوس. مهمتك: **شخّص وأصلح** حتى ينجح `./verify.sh` (من مجلد `startup/`).

```bash
cd startup
cp .env.example .env
break-fix/run.sh up 01      # شغّل السيناريو
break-fix/run.sh down 01    # أوقفه قبل الانتقال لغيره
```

> لا تفتح [`SOLUTIONS.md`](SOLUTIONS.md) قبل أن تحاول جديًّا. أصلح بتعديل **ملف السيناريو** (أو `Caddyfile.03`)، وليس `compose.yaml` الأصلي.

| # | الملف | العَرَض |
|---|---|---|
| 01 | `01-wrong-hostname.yaml` | `up -d` ينتهي برسالة أن الحاوية `app` **unhealthy** ولا يعمل شيء على `localhost:8080`. |
| 02 | `02-wrong-healthcheck.yaml` | الأمر نفسه: `app` unhealthy. لكن سجلات `app` تقول إن gunicorn يعمل بلا مشاكل! |
| 03 | `03-bad-gateway.yaml` | كل الحاويات `healthy`، لكن المتصفح يعرض **502 Bad Gateway**. |
| 04 | `04-port-clash.yaml` | `up -d` يفشل برسالة عن منفذ مستخدم أو محجوز (port is already allocated). |

## سيناريو 05: فخّ كلمة المرور (يدوي)
هذا خطأ يقع فيه المحترفون أيضًا. نفّذ الخطوات بالترتيب:
1. شغّل المكدّس السليم: `docker compose up -d --build` وتأكد أن `./verify.sh` ينجح.
2. غيّر `POSTGRES_PASSWORD` في `.env` إلى قيمة جديدة.
3. `docker compose down` ثم `docker compose up -d` (بدون `-v`).
4. لماذا صار `app` unhealthy رغم أن الإعدادات "صحيحة"؟ كيف تصلحه بدون خسارة البيانات؟

## تلميحات عامة
```bash
docker compose ps
docker compose logs --tail 30 app
docker inspect --format '{{json .State.Health.Log}}' startup-app-1
docker compose exec app sh
```
