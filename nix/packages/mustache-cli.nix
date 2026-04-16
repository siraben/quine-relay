{ lib, stdenv, ruby, fetchurl, makeWrapper }:

let
  gemName = "mustache";
  version = "1.1.1";
in
stdenv.mkDerivation {
  pname = "mustache-cli";
  inherit version;

  src = fetchurl {
    url = "https://rubygems.org/downloads/${gemName}-${version}.gem";
    hash = "sha256-kIkf3VC1ORnKM0yMEDHq2hIV540ibVeV5SPWEjonF9A=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ruby ];

  installPhase = ''
    runHook preInstall
    export GEM_HOME=$out/lib/ruby/gems
    mkdir -p $GEM_HOME
    ${ruby}/bin/gem install --no-document --install-dir $GEM_HOME $src
    mkdir -p $out/bin
    makeWrapper $GEM_HOME/bin/mustache $out/bin/mustache \
      --set GEM_HOME $GEM_HOME \
      --prefix PATH : ${ruby}/bin
    runHook postInstall
  '';

  meta = {
    description = "Mustache template CLI tool";
    homepage = "https://github.com/mustache/mustache";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "mustache";
  };
}
