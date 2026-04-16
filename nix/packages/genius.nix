{ lib, stdenv, fetchgit, autoreconfHook, pkg-config
, glib, gmp, mpfr, readline, ncurses, intltool, flex, bison
, autoconf-archive }:

stdenv.mkDerivation rec {
  pname = "genius";
  version = "0-unstable-2026-04-01";

  src = fetchgit {
    url = "https://gitlab.gnome.org/GNOME/genius.git";
    rev = "fef99cc52da3df83fbaef9bed6db54000b8018c3";
    hash = "sha256-BVzxYsBiQcC1ZXwI7BtbTeSOhlwOzV2GUnei8W+Eqgg=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config intltool flex bison autoconf-archive ];
  buildInputs = [ glib gmp mpfr readline ncurses ];

  configureFlags = [
    "--disable-gnome"
    "--disable-update-mimedb"
    "--disable-scrollkeeper"
  ];

  postPatch = ''
    # Replace the gtk-update-icon-cache check with a no-op
    sed -i 's|AC_PATH_PROG(GTK_UPDATE_ICON_CACHE.*|GTK_UPDATE_ICON_CACHE=true|' configure.ac
    # Remove gtkextra from SUBDIRS (it requires GTK)
    sed -i 's/gtkextra//g' Makefile.am
    sed -i '/gtkextra/d' configure.ac
  '';

  meta = {
    description = "Genius - a general purpose calculator and GEL programming language";
    homepage = "https://www.jirka.org/genius.html";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "genius";
  };
}
