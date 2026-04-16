{ lib, perlPackages, fetchurl }:

perlPackages.buildPerlPackage {
  pname = "Acme-Chef";
  version = "1.03";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/mame/quine-relay/master/vendor/Acme-Chef-1.03.tar.gz";
    hash = "sha256-XZNi3thLJxfWHEeloc/RM5XVWa3RWK/QsImbNkS7z0w=";
  };

  meta = {
    description = "An interpreter/compiler for the Chef programming language";
    license = lib.licenses.artistic1;
    mainProgram = "compilechef";
  };
}
