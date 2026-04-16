{ lib, stdenv, runCommand, wrapCC, gcc, flex, libgcc }:

let
  gccWithM2 = gcc.cc.overrideAttrs (old: {
    configureFlags = (builtins.filter (f:
      !(builtins.isString f && lib.hasPrefix "--enable-languages=" f)
    ) old.configureFlags) ++ [ "--enable-languages=c,c++,m2,objc" ];

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ flex ];
  });
in
runCommand "gm2-wrapper" {} ''
  mkdir -p $out/bin
  cat > $out/bin/gm2 <<'WRAPPER'
  #!/bin/sh
  exec @gm2@ \
    -B@libc@/lib \
    -B@gcc_lib_dir@/ \
    -L@libc@/lib \
    -L@gcc_lib@/lib \
    -L@libgcc@/lib \
    "$@"
  WRAPPER
  substituteInPlace $out/bin/gm2 \
    --replace-fail '@gm2@' '${gccWithM2}/bin/gm2' \
    --replace-fail '@libc@' '${stdenv.cc.libc}' \
    --replace-fail '@gcc_lib_dir@' '${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.cc.version}' \
    --replace-fail '@gcc_lib@' '${stdenv.cc.cc.lib}' \
    --replace-fail '@libgcc@' '${libgcc.lib}'
  chmod +x $out/bin/gm2

  # Also provide a gcc that supports Objective-C (step 109 needs it)
  cat > $out/bin/gcc-objc <<'WRAPPER'
  #!/bin/sh
  exec @gm2_gcc@ \
    -B@libc@/lib \
    -B@gcc_lib_dir@/ \
    -L@libc@/lib \
    -L@gcc_lib@/lib \
    -L@libgcc@/lib \
    "$@"
  WRAPPER
  substituteInPlace $out/bin/gcc-objc \
    --replace-fail '@gm2_gcc@' '${gccWithM2}/bin/gcc' \
    --replace-fail '@libc@' '${stdenv.cc.libc}' \
    --replace-fail '@gcc_lib_dir@' '${stdenv.cc.cc}/lib/gcc/x86_64-unknown-linux-gnu/${stdenv.cc.cc.version}' \
    --replace-fail '@gcc_lib@' '${stdenv.cc.cc.lib}' \
    --replace-fail '@libgcc@' '${libgcc.lib}'
  chmod +x $out/bin/gcc-objc
''
