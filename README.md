# Claude Code على Termux

تثبيت [Claude Code](https://github.com/anthropics/claude-code) على أندرويد عن طريق Termux بأمر واحد.

> ده مشروع مش رسمي. Anthropic مش بتدعم أندرويد رسميًا.

## المتطلبات
- موبايل أندرويد بمعالج arm64 (أغلب الموبايلات الحديثة).
- Termux من [F-Droid](https://f-droid.org/packages/com.termux/) أو [GitHub](https://github.com/termux/termux-app/releases)، مش من جوجل بلاي.
- اشتراك Claude أو مفتاح API.

## التثبيت
افتح Termux والصق الأمر ده:

```bash
curl -fsSL https://raw.githubusercontent.com/stonxmg-lang/claude-termux/main/install.sh | bash
```

لما يخلص، اقفل Termux وافتحه تاني واكتب:

```bash
claude
```

## لو حصلت مشكلة
- **أثناء التثبيت:** السكريبت هيسألك لو عايز ترفع السجل. اختار `y` وابعت اللينك اللي هيطلع.
- **بعد التثبيت:** اكتب `claude-report` واختار `y` وابعت اللينك.

السجل بيتحفظ كمان على جهازك في `~/claude-termux-install.log`.

> تنبيه: اللينك بيكون عام على paste.rs. السجل فيه معلومات الجهاز ومخرجات التثبيت بس، ومفيهوش أي باسوردات أو مفاتيح.

## إزاي بيشتغل
بيثبّت `nodejs` و `glibc-runner`، وبعدين Claude Code من npm، ويشغّل نسخة linux-arm64 عن طريق `grun`.
