{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "lazyk";
  version = "0-unstable-2024-07-08";

  src = fetchFromGitHub {
    owner = "irori";
    repo = "lazyk";
    rev = "35699d9e94647c7b9450339162e708d6b2765b7d";
    hash = "sha256-hbNu4SlGpGMnZeUe7vqg/OtOiDllVVqKdtDMLTwv+m4=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm755 lazyk $out/bin/lazyk
    runHook postInstall
  '';

  meta = {
    description = "Lazy K programming language interpreter";
    homepage = "https://github.com/irori/lazyk";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "lazyk";
  };
}
