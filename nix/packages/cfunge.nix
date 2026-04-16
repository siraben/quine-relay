{ lib, stdenv, fetchFromGitHub, cmake, ncurses, libbsd }:

stdenv.mkDerivation rec {
  pname = "cfunge";
  version = "0-unstable-2025-10-04";

  src = fetchFromGitHub {
    owner = "VorpalBlade";
    repo = "cfunge";
    rev = "29e4cfa1cc1f4553bf0e2908f819e913c32dfda8";
    hash = "sha256-Vb1Cg4h+uDk4I8XFnTnoS1LsHQVH1xg58wDpEeZF/R8=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ ncurses libbsd ];

  meta = {
    description = "A fast Befunge-93/98/109 interpreter in C";
    homepage = "https://github.com/VorpalBlade/cfunge";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "cfunge";
  };
}
