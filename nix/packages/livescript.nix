{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "livescript";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "gkz";
    repo = "LiveScript";
    rev = version;
    hash = "sha256-H1h2Qaiod6wI4XsTlW9oCCzlm5pgTXubfgnj82HLkx0=";
  };

  postPatch = ''
    cp ${./livescript-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-p1tCL6NZl2arObYF0fUCLFBJlVVLsI6cbupaFOPLVw8=";
  dontNpmBuild = true;

  meta = {
    description = "LiveScript - a language that compiles to JavaScript";
    homepage = "https://livescript.net/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "lsc";
  };
}
