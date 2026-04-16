{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "squirrel";
  version = "0-unstable-2026-02-28";

  src = fetchFromGitHub {
    owner = "albertodemichelis";
    repo = "squirrel";
    rev = "f9267f2f2a9afa1face89d8ea078c686331e30d1";
    hash = "sha256-cElXmwSR238kOc0si/jVk6bi7ajVyf0vD+yfXr1AYrs=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DLONG_OUTPUT_NAMES=ON"
  ];

  postInstall = ''
    # quine-relay expects the binary to be called 'squirrel'
    ln -s $out/bin/squirrel3 $out/bin/squirrel
  '';

  meta = {
    description = "Squirrel - a light-weight scripting language";
    homepage = "http://squirrel-lang.org/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "squirrel";
  };
}
