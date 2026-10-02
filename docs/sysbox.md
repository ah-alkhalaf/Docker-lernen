# اختياري: Sysbox لصناديق فيها systemd وDocker

> **تنبيه صدق:** هذا الملف **وصف اتجاه** ولم يُختبر في هذا المستودع. اتبع وثائق Sysbox الرسمية، وتحقق من الصور المذكورة قبل الاعتماد عليها.

## لماذا؟
صندوق المختبر الافتراضي حاوية عادية: لا يوجد فيها `systemd`، ولا يمكن تشغيل Docker بداخلها بأمان. [Sysbox](https://github.com/nestybox/sysbox) هو "runtime" بديل يشغّل **حاويات نظام** تتصرف كخادم صغير: فيها `systemd` ويمكن تشغيل Docker بداخلها **دون** `--privileged`، وفيها عزل user namespace أقوى.

## متى تحتاجه؟
- لتدريب حي على `systemctl` و`journalctl` (الجلسة 4).
- لتشغيل الجلسات 6–8 **داخل** الصندوق بدل أجهزة الأصدقاء.

## الشروط
- مضيف **لينكس** فقط (لا يعمل على macOS أو Windows مع Docker Desktop).
- تثبيت Sysbox حسب وثائقه، ثم التأكد من `docker info | grep -i runtimes` أنه يظهر `sysbox-runc`.

## الفكرة العملية (غير مختبرة)
```bash
docker run -d --name sysbox-box --runtime=sysbox-runc -p 2301:22 \
  nestybox/ubuntu-jammy-systemd-docker
```
ثم تهيئة مستخدم وSSH داخلها حسب وثائق الصورة. وتأكد أولًا أن الصورة تتضمن `sshd`، وإلا ثبّته داخلها بـ `apt install openssh-server`.
البديل الأنظف: ابنِ صورتك الخاصة (`FROM nestybox/ubuntu-jammy-systemd-docker`) تضيف إليها مستخدم `student` ومجلد `lab/` من هذا المستودع.
