{ lib, symlinkJoin, spl2c, cfunge, lazyk, npiet, lolcode, velato-01, acme-chef }:

# Build the vendor/local directory tree that the quine-relay Makefile expects
symlinkJoin {
  name = "quine-relay-vendor-local";
  paths = [
    spl2c         # provides bin/spl2c, lib/libspl.a, include/spl.h
    cfunge        # provides bin/cfunge
    lazyk         # provides bin/lazyk
    npiet         # provides bin/npiet
    lolcode       # provides bin/lolcode-lci (we'll add lci symlink)
    velato-01     # provides bin/Vlt.exe + DLLs (Velato 0.1, not 2.x)
    acme-chef     # provides bin/compilechef, lib/perl5/...
  ];

  postBuild = ''
    # The Makefile expects 'lci' not 'lolcode-lci'
    if [ -f $out/bin/lolcode-lci ] && [ ! -f $out/bin/lci ]; then
      ln -s lolcode-lci $out/bin/lci
    fi
  '';

  meta = {
    description = "Pre-built vendor tools for quine-relay";
  };
}
