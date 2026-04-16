{
  description = "Nix flake for quine-relay — all 128 programming language tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      overlay = import ./nix/overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
          config.permittedInsecurePackages = [ "mbedtls-2.28.10" ];
        };

        inherit (pkgs) lib;

        # === Binary-name compatibility wrappers ===
        #
        # The quine-relay Makefile expects specific binary names that differ
        # from what nixpkgs provides. These wrappers bridge the gap.

        wrapBin = name: target: pkgs.writeShellScriptBin name ''exec ${target} "$@"'';
        linkBin =
          name: target: pkgs.runCommand name { } "mkdir -p $out/bin; ln -s ${target} $out/bin/${name}";

        lci-wrapper = wrapBin "lci" "${pkgs.lolcode}/bin/lolcode-lci";
        bsh-wrapper = pkgs.writeShellScriptBin "bsh" ''
          exec ${pkgs.jdk}/bin/java -classpath ${pkgs.bsh} bsh.Interpreter "$@"
        '';
        lua53-link = linkBin "lua5.3" "${pkgs.lua5_3}/bin/lua";
        gbr3-link = linkBin "gbr3" "${pkgs.gambas3}/bin/.gbx3-wrapped";

        # === Behavioural fix wrappers ===
        #
        # These wrappers fix runtime issues in upstream tools when running
        # under Nix (missing paths, encoding bugs, terminal handling, etc.)

        # scilab-bin 6.1.1 leaks "grep: warning:" to stdout, corrupting relay output
        scilab-cli-wrapper = pkgs.writeShellScriptBin "scilab-cli" ''
          ${pkgs.scilab-bin}/bin/scilab-cli "$@" | grep -v '^grep: warning:'
        '';

        # AFNIX OutputTerm double-encodes UTF-8 bytes as Unicode codepoints
        axi-wrapper = pkgs.writeShellScriptBin "axi" ''
          ${pkgs.afnix}/bin/axi "$@" | ${pkgs.python3}/bin/python3 -c "
          import sys; data = sys.stdin.buffer.read()
          sys.stdout.buffer.write(bytes(ord(c) for c in data.decode('utf-8')))"
        '';

        # gbs3.gambas uses #!/usr/bin/env gbr3; Qt wrapQtAppsHook broke argv[0]
        gbs3-wrapper = pkgs.writeShellScriptBin "gbs3" ''
          exec ${gbr3-link}/bin/gbr3 ${pkgs.gambas3}/bin/gbs3.gambas -- "$@"
        '';

        # BeanShell disables terminal echo; @stty echo in Makefile fails without tty
        stty-wrapper = pkgs.writeShellScriptBin "stty" ''
          ${pkgs.coreutils}/bin/stty "$@" 2>/dev/null || true
        '';

        # === Build tool wrappers ===
        #
        # The Makefile uses gcc/make with assumptions that break under Nix.

        # Makefile sets CLASSPATH:=. which overrides env; command-line overrides Makefile
        make-wrapper = pkgs.writeShellScriptBin "make" ''
          exec ${pkgs.gnumake}/bin/make CLASSPATH=".:${pkgs.aspectj}/lib/aspectjrt.jar" "$@"
        '';

        # gcc wrapper: routes .m (ObjC) to our ObjC-capable GCC, and
        # replaces -std=c99 with -std=gnu89 for INTERCAL's K&R C output
        gcc-wrapper = pkgs.writeShellScriptBin "gcc" ''
          args=("$@")
          has_ick=false has_objc=false
          for a in "''${args[@]}"; do
            [[ "$a" == "-lick" ]] && has_ick=true
            [[ "$a" == *.m ]]    && has_objc=true
          done
          if $has_ick; then args=("''${args[@]/-std=c99/-std=gnu89}"); fi
          if $has_objc; then exec ${pkgs.gm2}/bin/gcc-objc "''${args[@]}"; fi
          exec ${pkgs.gcc}/bin/gcc "''${args[@]}"
        '';

        # gdc flag translation: gdc -o X Y.d → ldc2 -of=X Y.d
        gdc-wrapper = pkgs.writeShellScriptBin "gdc" ''
          args=(); i=0
          while [ $i -lt $# ]; do
            arg="''${@:$((i+1)):1}"
            case "$arg" in
              -o) i=$((i+1)); args+=("-of=''${@:$((i+1)):1}") ;;
              *)  args+=("$arg") ;;
            esac
            i=$((i+1))
          done
          exec ${pkgs.ldc}/bin/ldc2 "''${args[@]}"
        '';

        # All wrappers that must appear before system binaries on PATH
        wrapperPath = lib.makeBinPath [
          make-wrapper
          gcc-wrapper
          stty-wrapper
          gbs3-wrapper
          gbr3-link
          lua53-link
        ];
      in
      {
        packages = {
          inherit (pkgs)
            lazyk
            ratfor
            cimfomfa
            zoem
            velato
            cfunge
            squirrel
            nickle
            spl2c
            livescript
            mustache-cli
            afnix
            genius
            yorick
            gpt-portugol
            parser3
            swift-bin
            gambas3
            aplus
            intercal
            npiet
            icon-lang
            gm2
            acme-chef
            vendor-env
            ;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Languages listed in quine-relay order (1–128).
            # (v) = handled by ruby vendor/*.rb scripts, no separate package needed.
            # (w) = handled by a wrapper script defined above.
            #  1 Ruby       2 Rust       3 Scala      4 Scheme
            ruby
            rustc
            cargo
            scala
            guile
            #  5 Scilab     6 sed        7 Shakespeare 8 S-Lang
            scilab-bin
            gnused
            spl2c
            slang
            #  9 Squirrel  10 Std ML    11 Subleq(v)  12 SurgeScript
            squirrel
            polyml
            surgescript
            # 13 Swift     14 Tcl       15 tcsh       16 Thue(v)
            swift-bin
            tcl
            tcsh
            # 17 TypeScript 18 Unlambda(v) 19 Vala    20 Velato
            typescript
            vala
            glib
            velato
            # 21 Verilog   22 Vimscript  23 Visual Basic 24-25 WebAssembly
            iverilog
            vim
            dotnet-sdk
            wabt
            wasmtime
            # 26 Whitespace(v) 27 XSLT  28 Yabasic   29 Yorick
            libxslt
            yabasic
            yorick
            # 30 Zoem      31 zsh       32 A+         33 Ada
            zoem
            zsh
            aplus
            gnat
            # 34 AFNIX     35 Aheui(v)  36 ALGOL 68   37 Ante(v)
            afnix
            algol68g
            # 38 AspectJ   39 Asymptote 40 ATS        41 Awk
            aspectj
            asymptote
            ats2
            gawk
            # 42 bash      43 bc        44 BeanShell(w) 45 Befunge
            bash
            bc
            cfunge
            # 46 BLC8(v)   47 Brainfuck(v) 48 C       49 C++
            gcc
            # 50 C#        51 Chef(v)   52 Clojure    53 CMake
            mono
            clojure
            cmake
            # 54 COBOL     55 CoffeeScript 56 Common Lisp 57 Crystal
            gnucobol.bin
            coffeescript
            clisp
            crystal
            # 58 D         59 dc        60 Dhall      61 Elixir
            ldc
            dhall
            elixir
            # 62 Emacs Lisp 63 Erlang   64 Execline   65 F#
            emacs
            erlang
            execline
            # 66 FALSE(v)  67 Flex      68 Fish       69 Forth
            flex
            fish
            gforth
            # 70 FORTRAN77 71 Fortran90 72 Gambas     73 GAP
            f2c
            gfortran
            gambas3
            gap
            # 74 GDB       75 GEL      76 Gnuplot     77 Go
            gdb
            genius
            gnuplot
            go
            # 78 GolfScript(v) 79 G-Portugol 80 Grass(v) 81 Groovy
            gpt-portugol
            groovy
            # 82 Gzip      83 Haskell   84 Haxe       85 Icon
            gzip
            ghc
            haxe
            icon-lang
            # 86 INTERCAL  87 Jasmin    88 Java        89 JavaScript
            intercal
            jasmin
            jdk
            nodejs
            # 90 Jq        91 JSFuck    92 Kotlin      93 ksh
            jq
            kotlin
            ksh
            # 94 Lazy K    95 LiveScript 96 LLVM asm   97 LOLCODE
            lazyk
            livescript
            llvm
            lolcode
            # 98 Lua       99 M4       100 Makefile   101 MiniZinc
            lua5_3
            m4
            gnumake
            minizinc
            #102 Modula-2 103 MSIL     104 Mustache   105 NASM
            gm2
            mustache-cli
            nasm
            #106 Neko     107 Nickle   108 Nim        109 Objective-C(w)
            neko
            nickle
            nim
            #110 OCaml    111 Octave   112 Ook!(v)    113 PARI/GP
            ocaml
            octave
            pari
            #114 Parser 3 115 Pascal   116 Perl 5     117 Perl 6
            parser3
            fpc
            perl
            rakudo
            #118 PHP      119 Piet     120 Pike       121 PostScript
            php
            npiet
            pike
            ghostscript
            #122  Prolog       123  Promela     124  Python         125  R
            swi-prolog
            spin
            python3
            R
            #126  Ratfor       127  rc          128  REXX
            ratfor
            rc
            regina

            # Build tools needed by multiple steps
            pkg-config
            bison

            # Pre-built vendor/local tree (spl2c, cfunge, lazyk, npiet, lolcode, velato, acme-chef)
            vendor-env

            # Wrappers (shadowed via shellHook PATH prepend)
            lci-wrapper
            bsh-wrapper
            gdc-wrapper
            scilab-cli-wrapper
            axi-wrapper
            gbs3-wrapper
            gbr3-link
            lua53-link
          ];

          # INTERCAL headers and static libc for ick-generated C code
          C_INCLUDE_PATH = "${pkgs.intercal}/include/ick-0.30";
          LIBRARY_PATH = lib.makeLibraryPath [
            pkgs.intercal
            pkgs.glibc.static
          ];

          shellHook = ''
            # Shadow system binaries with our wrappers
            export PATH="${wrapperPath}:$PATH"

            # Copy vendor/local (not symlink — Velato writes to exe directory)
            setup_vendor() {
              local vdir="$1/vendor"
              if [ -d "$vdir" ] && [ ! -f "$vdir/local/.nix-setup-done" ]; then
                rm -rf "$vdir/local"
                cp -rL ${pkgs.vendor-env} "$vdir/local"
                chmod -R u+w "$vdir/local"
                touch "$vdir/local/.nix-setup-done"
              fi
            }
            setup_vendor "."
            setup_vendor "upstream"

            echo "quine-relay development environment — all 128 languages"
            echo "Run: cd upstream && make"
          '';
        };
      }
    )
    // {
      overlays.default = overlay;
    };
}
