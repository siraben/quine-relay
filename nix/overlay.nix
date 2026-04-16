final: prev: {
  # === Vendor environment (pre-built vendor/local for quine-relay) ===
  acme-chef = final.callPackage ./packages/acme-chef.nix { };
  velato-01 = final.callPackage ./packages/velato-01.nix { };
  vendor-env = final.callPackage ./packages/vendor-env.nix { };

  # === Custom packages not in nixpkgs ===
  lazyk       = final.callPackage ./packages/lazyk.nix { };
  ratfor      = final.callPackage ./packages/ratfor.nix { };
  cimfomfa    = final.callPackage ./packages/cimfomfa.nix { };
  zoem        = final.callPackage ./packages/zoem.nix { };
  velato      = final.callPackage ./packages/velato.nix { };
  cfunge      = final.callPackage ./packages/cfunge.nix { };
  squirrel    = final.callPackage ./packages/squirrel.nix { };
  nickle      = final.callPackage ./packages/nickle.nix { };
  spl2c       = final.callPackage ./packages/spl2c.nix { };
  livescript  = final.callPackage ./packages/livescript.nix { };
  mustache-cli = final.callPackage ./packages/mustache-cli.nix { };
  afnix       = final.callPackage ./packages/afnix.nix { };
  genius      = final.callPackage ./packages/genius.nix { };
  yorick      = final.callPackage ./packages/yorick.nix { };
  gpt-portugol = final.callPackage ./packages/gpt-portugol.nix { };
  parser3     = final.callPackage ./packages/parser3.nix { };
  swift-bin   = final.callPackage ./packages/swift-bin.nix { };
  gambas3     = final.callPackage ./packages/gambas3.nix { };
  aplus       = final.callPackage ./packages/aplus.nix { };
  gm2         = final.callPackage ./packages/gm2.nix { };

  # === Nixpkgs overrides (GCC 15 / C23 compatibility) ===

  # mbedtls-2 tests fail on current nixpkgs; needed by haxe
  mbedtls_2 = prev.mbedtls_2.overrideAttrs { doCheck = false; };

  # intercal: force stdbool.h and C11 mode to avoid C23 bool keyword conflict
  intercal = prev.intercal.overrideAttrs (old: {
    env = (old.env or {}) // {
      NIX_CFLAGS_COMPILE = "-DHAVE_STDBOOL_H=1 -std=gnu11";
    };
  });

  # npiet: fix signal handler signature and use C11 for K&R declarations
  npiet = prev.npiet.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      sed -i 's/^do_signal ()/do_signal (int sig __attribute__((unused)))/' npiet.c
    '';
    env = (old.env or {}) // { NIX_CFLAGS_COMPILE = "-std=gnu11"; };
  });

  # icon-lang: use C11 for K&R function declarations
  icon-lang = prev.icon-lang.overrideAttrs (old: {
    env = (old.env or {}) // { NIX_CFLAGS_COMPILE = "-std=gnu11"; };
  });
}
