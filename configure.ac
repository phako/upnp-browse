AC_PREREQ([2.64])
AC_INIT([upnp-browse],
        [0.1])

AC_CONFIG_AUX_DIR([build-aux])

AC_CONFIG_SRCDIR([src/browse.vala])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
AM_PROG_CC_C_O

dnl Initialize automake
AM_INIT_AUTOMAKE([1.11.1 tar-ustar no-dist-gzip dist-xz])
AM_MAINTAINER_MODE([enable])
AM_SILENT_RULES([yes])

PKG_CHECK_MODULES(GUPNP, gupnp-1.0 >= 0.18 gupnp-av-1.0 >= 0.9)
AC_CHECK_LIB([readline],[main],
            [AC_SUBST([READLINE_LIBS], ["-lreadline"])],
            [AC_MSG_ERROR([libreadline support not found])])

AC_ARG_ENABLE([vala],
              [AS_HELP_STRING([--enable-vala],
                              [enable building from vala sources])],,
              [enable_vala=no])
AS_IF([test "x$enable_vala" = xyes],
      [
       AM_PROG_VALAC([0.14])

       AS_IF([test "x$VALAC" = "x"],
             [AC_MSG_ERROR([Cannot find the "valac" compiler in your PATH])],
             [
              VALA_CHECK_PACKAGES([readline gupnp-1.0 gupnp-av-1.0])
             ])
       ],
       []
)

AC_CONFIG_FILES([
Makefile
src/Makefile
])

AC_OUTPUT
