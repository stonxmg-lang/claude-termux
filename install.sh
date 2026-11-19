#!/data/data/com.termux/files/usr/bin/bash
# تثبيت Claude Code على Termux (أندرويد arm64)
# كل اللي بيظهر بيتسجل في ~/claude-termux-install.log
# ولو حصلت مشكلة، السكريبت يعرض رفع السجل ويديك لينك تبعته لحد يساعدك.

LOG="$HOME/claude-termux-install.log"
REPO_RAW="https://raw.githubusercontent.com/stonxmg-lang/claude-termux/main"
PKG_DIR="$PREFIX/lib/node_modules/@anthropic-ai"
BIN="$PKG_DIR/claude-code-linux-arm64/claude"

: > "$LOG"
exec > >(tee -a "$LOG") 2>&1
set -E -o pipefail

STEP="البداية"
step() { STEP="$1"; echo; echo "==> $1"; }

upload_log() {
  echo
  echo "تحب ترفع سجل التثبيت عشان حد يقدر يساعدك؟ (السجل هيبقى على رابط عام في paste.rs) [y/n]"
  read -r ans </dev/tty
  if [[ $ans == [yYنن]* ]]; then
    url=$(curl -fsS --data-binary @"$LOG" https://paste.rs/)
    if [[ -n $url ]]; then
      echo; echo "🔗 ابعت اللينك ده للي هيساعدك:"; echo "   $url"
    else
      echo "الرفع فشل. السجل موجود هنا: $LOG"
    fi
  else
    echo "السجل موجود هنا: $LOG"
  fi
}

on_error() {
  local code=$?
  trap - ERR
  echo
  echo "❌ التثبيت وقف عند: $STEP (كود الخطأ $code)"
  upload_log
  exit 1
}
trap on_error ERR

# ---------- معلومات الجهاز (بتساعد في تشخيص المشكلة) ----------
step "معلومات الجهاز"
echo "التاريخ: $(date -u +%FT%TZ)"
echo "المعالج: $(uname -m)"
echo "أندرويد: $(getprop ro.build.version.release 2>/dev/null) (SDK $(getprop ro.build.version.sdk 2>/dev/null))"
echo "الجهاز: $(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
echo "Termux: ${TERMUX_VERSION:-غير معروف} | مصدر التثبيت: ${TERMUX_APK_RELEASE:-غير معروف}"
echo "المساحة الفاضية: $(df -h "$HOME" | awk 'NR==2{print $4}')"

if [[ $(uname -m) != aarch64 ]]; then
  echo "الجهاز ده مش arm64 (aarch64)، و Claude Code مش هيشتغل عليه."
  false
fi
if [[ ${TERMUX_APK_RELEASE:-} == GOOGLE_PLAY_STORE ]]; then
  echo "تحذير: Termux من جوجل بلاي ممكن يعمل مشاكل. الأفضل تنزله من F-Droid أو GitHub."
fi

# ---------- الحزم ----------
step "تحديث الحزم"
export DEBIAN_FRONTEND=noninteractive
pkg update -y </dev/null
apt-get -y -o Dpkg::Options::=--force-confnew upgrade </dev/null

step "تثبيت nodejs و glibc"
pkg install -y nodejs curl glibc-repo </dev/null
pkg install -y glibc-runner </dev/null

step "التأكد من إصدار node"
node -v
if (( $(node -p 'process.versions.node.split(".")[0]') < 22 )); then
  echo "محتاج node 22 أو أحدث."
  false
fi

# ---------- Claude Code ----------
step "تثبيت Claude Code"
npm install -g --allow-scripts=@anthropic-ai/claude-code @anthropic-ai/claude-code@latest </dev/null
VER=$(node -p "require('$PKG_DIR/claude-code/package.json').version")
echo "الإصدار: $VER"

step "تثبيت نسخة linux-arm64"
ARM_VER=$(node -p "try{require('$PKG_DIR/claude-code-linux-arm64/package.json').version}catch(e){''}")
if [[ ! -x $BIN || $ARM_VER != "$VER" ]]; then
  npm install -g --force "@anthropic-ai/claude-code-linux-arm64@$VER" </dev/null
fi
ls -la "$BIN"

step "تجربة التشغيل"
grun "$BIN" --version

step "إضافة أمر claude"
LINE="alias claude='grun $BIN'"
touch "$HOME/.bashrc"
if ! command grep -qF "$LINE" "$HOME/.bashrc"; then
  echo "$LINE" >> "$HOME/.bashrc"
fi

step "تجهيز أمر claude-report"
curl -fsSL "$REPO_RAW/report.sh" -o "$PREFIX/bin/claude-report"
chmod +x "$PREFIX/bin/claude-report"

trap - ERR
echo
echo "✅ تم التثبيت."
echo "اقفل Termux وافتحه تاني، واكتب: claude"
echo "لو Claude مشتغلش بعد كده، اكتب: claude-report"
