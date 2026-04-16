{ lib, stdenv, fetchFromGitHub, mono, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "velato";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "rottytooth";
    repo = "Velato";
    rev = version;
    hash = "sha256-wFjdIiTEsRDwM2owDO6y51jnXWO92QIT9HGPICdQ3jQ=";
  };

  nativeBuildInputs = [ mono makeWrapper ];

  buildPhase = ''
    runHook preBuild
    xbuild /p:Configuration=Release Rottytooth.Esolang.Velato/Rottytooth.Esolang.Velato.csproj
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/velato $out/bin
    cp Rottytooth.Esolang.Velato/bin/Release/*.exe $out/lib/velato/
    cp Rottytooth.Esolang.Velato/bin/Release/*.dll $out/lib/velato/
    # quine-relay expects Vlt.exe
    ln -s $out/lib/velato/Velato.exe $out/lib/velato/Vlt.exe
    makeWrapper ${mono}/bin/mono $out/bin/velato \
      --add-flags "$out/lib/velato/Velato.exe"
    makeWrapper ${mono}/bin/mono $out/bin/Vlt.exe \
      --add-flags "$out/lib/velato/Vlt.exe"
    runHook postInstall
  '';

  meta = {
    description = "Velato - an esoteric programming language using MIDI files";
    homepage = "https://github.com/rottytooth/Velato";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
  };
}
