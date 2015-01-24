
# Check if a GNAT project is available.
AC_DEFUN(AM_GNAT_CHECK_PROJECT,
[
  AC_MSG_CHECKING([whether $1 project exists])
  echo "with \"$1\"; project t is for Source_Dirs use (); end t;" > t.gpr
  $GNATMAKE -p -Pt >/dev/null 2>/dev/null
  if test $? -eq 0; then
    gnat_project_$1=yes
    AC_MSG_RESULT(yes, using $1)
    gnat_project_with_$1="with \"$1\";";
  else
    gnat_project_$1=no
    AC_MSG_RESULT(no)
  fi;
  rm -f t.gpr
])

dnl Check whether the shared library support is enabled.
AC_DEFUN(AM_SHARED_LIBRARY_SUPPORT,
[
  AC_MSG_CHECKING([shared library support])
  ac_enable_shared=no
  AC_ARG_ENABLE(shared,
    [  --enable-shared         Enable the shared libraries (disabled)],
    [case "${enableval}" in
      no|none)  ac_enable_shared=no ;;
      *)        ac_enable_shared=yes ;;
    esac])dnl

  AC_MSG_RESULT(${ac_enable_shared})
  BUILDS_SHARED=$ac_enable_shared
  AC_SUBST(BUILDS_SHARED)
])

dnl Check whether the AWS support is enabled and find the aws GNAT project.
AC_DEFUN(AM_GNAT_CHECK_AWS,
[
  dnl Define option to enable/disable AWS
  gnat_enable_aws=yes
  gnat_project_aws=
  AC_ARG_ENABLE(aws,
    [  --enable-aws            Enable the AWS support (enabled)],
    [case "${enableval}" in
      no|none)  gnat_enable_aws=no ;;
      *)        gnat_enable_aws=yes ;;
    esac])dnl

  AC_MSG_CHECKING([AWS support is enabled])
  AC_MSG_RESULT(${gnat_enable_aws})

  if test T$gnat_enable_aws = Tyes; then
    dnl AC_MSG_NOTICE([Ada Web Server library (http://libre.adacore.com/libre/tools/aws/)])
    AC_ARG_WITH(aws,
    AS_HELP_STRING([--with-aws=x], [Path for the Ada Web Server library (http://libre.adacore.com/libre/tools/aws/)]),
    [
      gnat_project_aws=${withval}
    ],
    [
      AM_GNAT_CHECK_PROJECT([aws])
      if test x$gnat_project_aws = x; then
        gnat_enable_aws=no
      else
        gnat_project_aws=aws
      fi
    ])
  fi
  if test T$gnat_enable_aws = Tno; then
    $1
  else
	$2
  fi
])

dnl Check by using xmlada-config where some files are installed.
dnl The goad is to find or guess some installation paths.
dnl           XML/Ada                    Debian
dnl *.ads     <prefix>/include/xmlada    <prefix>/usr/share/adainclude/xmlada  
dnl *.ali     <prefix>/lib/xmlada/static <prefix>/usr/lib/<arch>/ada/adalib/xmlada
dnl *.so      <prefix>/lib/xmlada/static <prefix>/usr/lib/<arch>
dnl *.prj     <prefix>/lib/gnat          <prefix>/usr/share/adainclude

AC_DEFUN(AM_GNAT_CHECK_INSTALL,
[
  #
  gnat_prefix=
  gnat_xml_inc_dir=
  gnat_xml_ali_dir=
  gnat_xml_lib_dir=
  gnat_xml_prl_dir=
  gnat_xml_config=`$gnat_xml_ada --sax 2>/dev/null`

  # echo "Config: $gnat_xml_config"
  for i in $gnat_xml_config; do
	# echo "  Checking $i"
	case $i in
	  -aI*)
	    name=`echo $i | sed -e 's,-aI,,'`
	    dir=`dirname $name`
	    name=`basename $name`
	    if test x$name = "xxmlada"; then
	   	   gnat_xml_inc_dir=$dir
		else
		   dir=''
	    fi
	    ;;

	 -aO*)
	    name=`echo $i | sed -e 's,-aO,,'`
	    dir=`dirname $name`
	    name=`basename $name`
		case $name in
		  xmlada)
	        gnat_xml_ali_dir=$dir
			;;

		  static|relocatable)
		    name=`basename $dir`
		    dir=`dirname $dir`
			if test x$name = "xxmlada"; then
			   gnat_xml_ali_dir=$dir
			else
			   dir=''
			fi
		    ;;

		  *)
		    dir=''
			;;

		esac
	    ;;

	-largs)
	    dir=''
		;;

     -L*)
	    dir=`echo $i | sed -e 's,-L,,'`
	    gnat_xml_lib_dir=$dir
	    ;;

	/*.a)
		dir=`dirname $i`
	    name=`basename $dir`
		case $name in
		  xmlada)
	        dir=`dirname $dir`
	        gnat_xml_lib_dir=$dir
			;;

		  static|relocatable)
		    dir=`dirname $dir`
		    name=`basename $dir`
			if test x$name = "xxmlada"; then
			   dir=`dirname $dir`
			   gnat_xml_lib_dir=$dir
			else
			   dir=''
			fi
		    ;;

		  *)
		    dir=''
			;;

		esac		
		;;

     *)
	    dir=
	    ;;
    esac

    # If we have a valid path, try to identify the common path prefix.
    if test x$dir != "x"; then
       if test x$gnat_prefix = x; then
          gnat_prefix=$dir
       else
	   # echo "Dir=$dir"
	   gnat_old_ifs=$IFS
	   path=
	   IFS=/
	   for c in $dir; do
	      if test x"$path" = x"/"; then
		    try="/$c"
		  else
			try="$path/$c"
		  fi
		  # echo "gnat_prefix=$gnat_prefix try=$try path=$path c=$c"
		  case $gnat_prefix in
		    $try*)
			   ;;
		    *)
			   break
			   ;;
		  esac
		  path=$try
	   done
	   IFS=$gnat_old_ifs
	   gnat_prefix=$path
       fi
    fi
  done

  if test -f $gnat_prefix/lib/gnat/xmlada.gpr ; then
    gnat_xml_prj_dir=$gnat_prefix/lib/gnat
  elif test -f $gnat_xml_inc_dir/xmlada.gpr ; then
    gnat_xml_prj_dir=$gnat_xml_inc_dir
  elif test -f $gnat_prefix/share/gpr/xmlada.gpr ; then
    gnat_xml_prj_dir=$gnat_prefix/share/gpr
  else
    gnat_xml_prj_dir=$gnat_xml_inc_dir
  fi
  ADA_INC_BASE=`echo $gnat_xml_inc_dir | sed -e s,^$gnat_prefix/,,`
  ADA_LIB_BASE=`echo $gnat_xml_lib_dir | sed -e s,^$gnat_prefix/,,`
  ADA_ALI_BASE=`echo $gnat_xml_ali_dir | sed -e s,^$gnat_prefix/,,`
  ADA_PRJ_BASE=`echo $gnat_xml_prj_dir | sed -e s,^$gnat_prefix/,,`

  AC_MSG_CHECKING([installation of Ada source files])
  AC_MSG_RESULT(<prefix>/${ADA_INC_BASE})

  AC_MSG_CHECKING([installation of Ada ALI files])
  AC_MSG_RESULT(<prefix>/${ADA_ALI_BASE})

  AC_MSG_CHECKING([installation of library files])
  AC_MSG_RESULT(<prefix>/${ADA_LIB_BASE})

  AC_MSG_CHECKING([installation of GNAT project files])
  AC_MSG_RESULT(<prefix>/${ADA_PRJ_BASE})

  AC_SUBST(ADA_INC_BASE)
  AC_SUBST(ADA_LIB_BASE)
  AC_SUBST(ADA_ALI_BASE)
  AC_SUBST(ADA_PRJ_BASE)
])

