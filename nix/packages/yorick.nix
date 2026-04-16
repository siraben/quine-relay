{ lib, stdenv, fetchFromGitHub, libx11, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "yorick";
  version = "0-unstable-2025-04-07";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "yorick";
    rev = "ea7012c87c379ee8e00ef8e0bde8e53f3fdb8492";
    hash = "sha256-gjabbLjVUPX9XrsrxDPTV4kmvd9sWRPmXDw+CRMqqbM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ libx11 ];

  hardeningDisable = [ "fortify" ];

  configurePhase = ''
    runHook preConfigure
    make ysite
    # Set both Y_HOME and Y_SITE to the same directory to avoid
    # duplicate loading of i-start files
    sed -i "s|Y_LAUNCH_DIR=.*|Y_LAUNCH_DIR=$out/lib/yorick|" ysite.sh
    sed -i "s|Y_SITE=.*|Y_SITE=$out/lib/yorick|" ysite.sh
    sed -i "s|Y_HOME=.*|Y_HOME=$out/lib/yorick|" ysite.sh
    make config
    runHook postConfigure
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    # Yorick installs relative to its Y_HOME
    make install
    # Copy the binary and essential files
    mkdir -p $out/bin $out/lib/yorick $out/share/yorick
    local platform=$(ls -d */lib/yorick 2>/dev/null | head -1 | cut -d/ -f1)
    if [ -z "$platform" ]; then
      platform="Linux-$(uname -m)"
    fi
    cp -r $platform/* $out/lib/yorick/ 2>/dev/null || true
    cp -r i0 i $out/share/yorick/ 2>/dev/null || true
    cp yorick/yorick $out/bin/.yorick-unwrapped
    makeWrapper $out/bin/.yorick-unwrapped $out/bin/yorick \
      --set Y_SITE $out/share/yorick \
      --set Y_HOME $out/lib/yorick
    runHook postInstall
  '';

  meta = {
    description = "Yorick - interpreted language for scientific computing";
    homepage = "https://github.com/LLNL/yorick";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "yorick";
  };
}
