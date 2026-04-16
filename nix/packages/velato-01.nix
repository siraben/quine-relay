{ lib, stdenv, fetchurl, unzip }:

# Velato 0.1 - the specific version quine-relay was built against
# This is a pre-built .NET binary that runs via mono
stdenv.mkDerivation {
  pname = "velato";
  version = "0.1";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/mame/quine-relay/master/vendor/Velato_0_1.zip";
    hash = "sha256-jnxkf0/oeXJUJwkpTUenz1VXw+tdA/l7V3+Wipi5Jec=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp Vlt.exe $out/bin/
    cp *.dll $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "Velato 0.1 - esoteric language using MIDI (prebuilt binary)";
    homepage = "https://github.com/rottytooth/Velato";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
}
