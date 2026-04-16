{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper
, icu, ncurses6, libedit, libxml2, curl, libuuid, python3
, zlib, libgcc, sqlite }:

stdenv.mkDerivation rec {
  pname = "swift-bin";
  version = "6.3";

  src = fetchurl {
    url = "https://download.swift.org/swift-${version}-release/ubuntu2204/swift-${version}-RELEASE/swift-${version}-RELEASE-ubuntu22.04.tar.gz";
    hash = "sha256-rx3SVpUqko4Z7pnWcFP1YSDC0gNjuW8gF+IDgJO/u0k=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [
    icu ncurses6 libedit libxml2 curl libuuid python3
    zlib stdenv.cc.cc.lib libgcc.lib sqlite
  ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out $out/swift-bin
    cp -r swift-${version}-RELEASE-ubuntu22.04/usr/* $out/swift-bin/

    # Remove lldb to save space
    rm -f $out/swift-bin/bin/lldb* 2>/dev/null || true

    # Create wrapper that sets up the linker search paths
    # Swift's clang needs to find: libc headers, crt*.o, libgcc, dynamic linker
    mkdir -p $out/bin
    cat > $out/bin/swiftc <<'WRAPPER'
    #!/bin/sh
    exec @out@/swift-bin/bin/swiftc \
      -Xcc --sysroot=/ \
      -Xcc -I@libc_dev@/include \
      -Xclang-linker -B@libc@/lib \
      -Xclang-linker -L@libc@/lib \
      -Xlinker -L@gcc_lib_dir@ \
      -Xclang-linker -B@gcc_lib_dir@ \
      -Xclang-linker -L@gcc_lib@/lib \
      -Xclang-linker -L@libgcc@/lib \
      -Xlinker --dynamic-linker=@libc@/lib/ld-linux-x86-64.so.2 \
      "$@"
    WRAPPER
    substituteInPlace $out/bin/swiftc \
      --replace-fail '@out@' "$out" \
      --replace-fail '@libc_dev@' "${stdenv.cc.libc.dev}" \
      --replace-fail '@libc@' "${stdenv.cc.libc}" \
      --replace-fail '@gcc_lib@' "${stdenv.cc.cc.lib}" \
      --replace-fail '@gcc_lib_dir@' "${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.cc.version}/" \
      --replace-fail '@libgcc@' "${libgcc.lib}"
    chmod +x $out/bin/swiftc

    # Also expose swift interpreter
    ln -s $out/swift-bin/bin/swift $out/bin/swift
    runHook postInstall
  '';

  # Some shared libraries may not be found; that's ok for our use case
  autoPatchelfIgnoreMissingDeps = [ "*" ];
  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Swift programming language (prebuilt binary)";
    homepage = "https://swift.org/";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "swiftc";
  };
}
