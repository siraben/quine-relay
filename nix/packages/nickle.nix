{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, bison, flex, readline, bc, gmp }:

stdenv.mkDerivation rec {
  pname = "nickle";
  version = "0-unstable-2026-03-14";

  src = fetchFromGitHub {
    owner = "keith-packard";
    repo = "nickle";
    rev = "8dc1c631c31b07be3419db2041ba459acf01450c";
    hash = "sha256-UT1Yi+RCYvyOMERtWmjfYlczzDdfuqNFlkqDtjribYI=";
  };

  nativeBuildInputs = [ meson ninja pkg-config bison flex bc ];
  buildInputs = [ readline gmp ];

  meta = {
    description = "Nickle - a desk calculator language with powerful programming features";
    homepage = "https://nickle.org/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "nickle";
  };
}
