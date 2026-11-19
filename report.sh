#!/data/data/com.termux/files/usr/bin/bash
# بيجمع تشخيص لحالة Claude Code على الجهاز ويرفعه برابط تبعته للي هيساعدك.

OUT="$HOME/claude-termux-report.log"
PKG_DIR="$PREFIX/lib/node_modules/@anthropic-ai"
BIN="$PKG_DIR/claude-code-linux-arm64/claude"

{
  echo "===== تقرير Claude على Termux ====="
  echo "التاريخ: $(date -u +%FT%TZ)"
  echo "المعالج: $(uname -m)"
  echo "أندرويد: $(getprop ro.build.version.release 2>/dev/null) (SDK $(getprop ro.build.version.sdk 2>/dev/null))"
  echo "الجهاز: $(getprop ro.product.manufacturer 2>/dev/null) $(getprop ro.product.model 2>/dev/null)"
  echo "Termux: ${TERMUX_VERSION:-?} | ${TERMUX_APK_RELEASE:-?}"
  echo "المساحة الفاضية: $(df -h "$HOME" | awk 'NR==2{print $4}')"
  echo
  echo "--- node / npm ---"
  node -v 2>&1; npm -v 2>&1
  echo
  echo "--- glibc ---"
  command -v grun 2>&1 || echo "grun مش موجود"
  ls "$PREFIX/glibc/lib/ld-linux-aarch64.so.1" 2>&1
  echo
  echo "--- حزم Claude ---"
  ls -la "$PKG_DIR" 2>&1
  for p in claude-code claude-code-linux-arm64; do
    [[ -f $PKG_DIR/$p/package.json ]] && echo "$p: $(node -p "require('$PKG_DIR/$p/package.json').version")"
  done
  echo
  echo "--- alias في bashrc ---"
  command grep -n claude "$HOME/.bashrc" 2>&1
  echo
  echo "--- تجربة التشغيل ---"
  grun "$BIN" --version 2>&1
  echo "كود الخروج: $?"
  echo
  if [[ -f $HOME/claude-termux-install.log ]]; then
    echo "--- آخر 150 سطر من سجل التثبيت ---"
    tail -n 150 "$HOME/claude-termux-install.log"
  fi
} > "$OUT" 2>&1

echo "التقرير اتحفظ في: $OUT"
echo "تحب ترفعه عشان حد يساعدك؟ (هيبقى على رابط عام في paste.rs) [y/n]"
read -r ans </dev/tty
if [[ $ans == [yYنن]* ]]; then
  url=$(curl -fsS --data-binary @"$OUT" https://paste.rs/)
  if [[ -n $url ]]; then
    echo "🔗 ابعت اللينك ده للي هيساعدك:"; echo "   $url"
  else
    echo "الرفع فشل."
  fi
fi
