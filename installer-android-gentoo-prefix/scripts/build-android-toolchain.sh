#!/usr/bin/env bash
set -euo pipefail

# Host-side builder for Android aarch64 (Bionic) binutils + GCC stage1
# - Uses NDK r26b Clang/LLD and sysroot
# - Produces runnable binaries for Android under builds/out-run-bin

NDK_DEFAULT="$PWD/toolchain-android/android-ndk-r26b"
NDK="${NDK:-$NDK_DEFAULT}"
API="${API:-30}"
TARGET="${TARGET:-aarch64-linux-android}"
PREFIX_DIR="${PREFIX_DIR:-$PWD/builds/out-run-bin}"
SRC_DIR="${SRC_DIR:-$PWD/builds/src}"
BUILD_DIR="${BUILD_DIR:-$PWD/builds/build}"
JOBS="${JOBS:-$(nproc || echo 4)}"

LLVM_BIN="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
BUILD_TRIPLET="${BUILD_TRIPLET:-$(gcc -dumpmachine 2>/dev/null || echo x86_64-pc-linux-gnu)}"

CC="$LLVM_BIN/${TARGET}${API}-clang"
CXX="$LLVM_BIN/${TARGET}${API}-clang++"
AR="$LLVM_BIN/llvm-ar"
RANLIB="$LLVM_BIN/llvm-ranlib"
AS="$LLVM_BIN/llvm-as"
LD="$LLVM_BIN/ld.lld"
STRIP="$LLVM_BIN/llvm-strip"
SYSROOT="$NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot"

export CC CXX AR RANLIB AS LD STRIP
# Do NOT leak sysroot into build-host tools. Keep generic CFLAGS for build.
export CFLAGS="-O2 -fPIC"
export CXXFLAGS="$CFLAGS"
export LDFLAGS=""
# Target flags for generated compilers/libraries
export CFLAGS_FOR_TARGET="--sysroot=$SYSROOT -D__ANDROID_API__=$API -fPIC"
export CXXFLAGS_FOR_TARGET="$CFLAGS_FOR_TARGET"
export LDFLAGS_FOR_TARGET="--sysroot=$SYSROOT"
export CC_FOR_BUILD="${CC_FOR_BUILD:-gcc}"
export CXX_FOR_BUILD="${CXX_FOR_BUILD:-g++}"
export CFLAGS_FOR_BUILD="${CFLAGS_FOR_BUILD:- -O2}"
export CXXFLAGS_FOR_BUILD="${CXXFLAGS_FOR_BUILD:- -O2}"

log() { printf "[build-toolchain] %s\n" "$*"; }
die() { echo "[build-toolchain][ERROR] $*" >&2; exit 1; }

[ -d "$NDK" ] || die "NDK not found at $NDK (override with NDK=...)"
mkdir -p "$SRC_DIR" "$BUILD_DIR" "$PREFIX_DIR"

# Versions
BINUTILS_VER="2.42"
GCC_VER="13.2.0"
SKIP_GCC="${SKIP_GCC:-0}"

cd "$SRC_DIR"
fetch() {
  local url="$1" out="$2"; local tries=3; local i=1
  while [ $i -le $tries ]; do
    if curl -fL --retry 3 --retry-delay 2 -o "$out" "$url"; then return 0; fi
    log "Download failed (try $i/$tries): $url"; i=$((i+1)); sleep 2
  done
  return 1
}

untar_or_refetch() {
  local tarball="$1" dir="$2" url_primary="$3" url_backup="$4"
  if tar -xf "$tarball"; then return 0; fi
  log "Corrupt archive detected: $tarball. Refetching..."
  rm -f "$tarball"
  if ! fetch "$url_primary" "$tarball"; then
    fetch "$url_backup" "$tarball"
  fi
  tar -xf "$tarball"
}

if [ ! -d "binutils-$BINUTILS_VER" ]; then
  log "Fetching binutils $BINUTILS_VER"
  if [ ! -f "binutils-$BINUTILS_VER.tar.xz" ]; then
    fetch "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz" "binutils-$BINUTILS_VER.tar.xz" || \
    fetch "https://sourceware.org/pub/binutils/releases/binutils-$BINUTILS_VER.tar.xz" "binutils-$BINUTILS_VER.tar.xz"
  fi
  untar_or_refetch "binutils-$BINUTILS_VER.tar.xz" "binutils-$BINUTILS_VER" \
    "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VER.tar.xz" \
    "https://sourceware.org/pub/binutils/releases/binutils-$BINUTILS_VER.tar.xz"
fi

if [ "$SKIP_GCC" != "1" ] && [ ! -d "gcc-$GCC_VER" ]; then
  log "Fetching gcc $GCC_VER"
  if [ ! -f "gcc-$GCC_VER.tar.xz" ]; then
    fetch "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz" "gcc-$GCC_VER.tar.xz" || \
    fetch "https://mirrors.kernel.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz" "gcc-$GCC_VER.tar.xz"
  fi
  untar_or_refetch "gcc-$GCC_VER.tar.xz" "gcc-$GCC_VER" \
    "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz" \
    "https://mirrors.kernel.org/gnu/gcc/gcc-$GCC_VER/gcc-$GCC_VER.tar.xz"
  (cd "gcc-$GCC_VER" && ./contrib/download_prerequisites)
fi

# Build binutils
mkdir -p "$BUILD_DIR/binutils-$BINUTILS_VER"
cd "$BUILD_DIR/binutils-$BINUTILS_VER"
if [ ! -f .configured ]; then
  log "Configuring binutils for host=$TARGET target=$TARGET"
  "$SRC_DIR/binutils-$BINUTILS_VER/configure" \
    --build="$BUILD_TRIPLET" \
    --host="$TARGET" \
    --target="$TARGET" \
    --prefix="/" \
    --disable-werror \
    --disable-nls \
    --disable-gprofng \
    --disable-gdb \
    --disable-gdbserver \
    --disable-sim \
    --with-sysroot="$SYSROOT"
  touch .configured
fi
log "Building binutils"
make -j"$JOBS"
log "Staging binutils to $PREFIX_DIR"
make DESTDIR="$PREFIX_DIR" install-strip

# Build gcc stage1 (C only)
if [ "$SKIP_GCC" != "1" ]; then
  mkdir -p "$BUILD_DIR/gcc-$GCC_VER"
  cd "$BUILD_DIR/gcc-$GCC_VER"
  if [ ! -f .configured ]; then
    log "Configuring gcc $GCC_VER stage1 (C only) for host=$TARGET target=$TARGET"
  "$SRC_DIR/gcc-$GCC_VER/configure" \
      --build="$BUILD_TRIPLET" \
      --host="$TARGET" \
      --target="$TARGET" \
      --prefix="/" \
      --enable-languages=c \
      --without-headers \
      --disable-nls \
      --disable-lto \
      --disable-plugin \
      --disable-multilib
    touch .configured
  fi
log "Building gcc stage1"
make -j"$JOBS" all-gcc GCC_FOR_TARGET="$(pwd)/gcc/xgcc -B$(pwd)/gcc"
log "Staging gcc to $PREFIX_DIR"
make DESTDIR="$PREFIX_DIR" install-gcc GCC_FOR_TARGET="$(pwd)/gcc/xgcc -B$(pwd)/gcc"
fi

log "Done. Binaries at: $PREFIX_DIR"
ls -l "$PREFIX_DIR/bin" || true
