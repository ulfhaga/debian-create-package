#!/bin/bash

# Create package for shell (No Makefile).
# https://www.debian.org/doc/manuals/debmake-doc/ch08.en.html#nomakefile
#set -x
set -e

declare -r SCRIPT=${0##*/}  || exit 201;  # SCRIPT is the name of this script
declare -r CDIR=$(dirname "$0")
declare -r DIR=$(pwd)

# Setup
declare -r pack_name=my-test-sh
declare -r version=1.0.0
declare -r revision=1
declare -r bash_file=my_test
declare -r man_file_name=my_test.1
declare -r DEBEMAIL="myname@gmail.com"
declare -r DEBFULLNAME="My Name"
declare -r Homepage=http:\/\/mysite.com


declare -r man_file=${DIR}/templates/"${man_file_name}"
declare -r shell_file="${DIR}"/templates/"${bash_file}"
declare -r base_folder="${DIR}"/target
export DEBEMAIL DEBFULLNAME



# Init

declare tar_boll=${pack_name}-${version}.tar.gz  
#declare -r temp_dir=$(mktemp -d)

main() {
  create_tar_ball;
  echo "Tar ball created:"
  ls -h ${base_folder}/${pack_name}/${tar_boll}

  echo "Untar ball"
  tar -xzmf ${base_folder}/${pack_name}/${tar_boll} -C ${base_folder}/${pack_name}
  cd ${base_folder}/${pack_name}/${pack_name}-${version}
# debmake -b':sh' -r ${revision}  -t -i debuild

# Helps to build a Debian package from the upstream source
  debmake -b':sh' -r ${revision}  

  

# Changelog
 sed -i -e 's/Initial release. Closes: #nnnn/Initial release./g'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
 sed -i -e '/is the bug number of your ITP/d'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
# sed -i -e 's/UNRELEASED/unstable/'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
 

# Copyright

 cp -f "${DIR}"/templates/copyright "${base_folder}/${pack_name}/${pack_name}-${version}/debian/"

# README.Debian   
  rm "${base_folder}/${pack_name}/${pack_name}-${version}/debian/README.Debian"

# Rules 
  sed -i -e'/You must remove/d'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/rules"
  sed -i -e '/export DH_VERBOSE/d'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/rules"

# Control file
  sed -i -e 's/Homepage: <insert the upstream URL, if relevant>/Homepage: http:\/\/adtoox.com/g'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/control"
  sed -i -e 's/Section: unknown/Section: devel/g'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/control"

# Install file 
  printf "scripts/${bash_file} usr/bin  " >  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/install"

# Create man pages
   printf   man/"${man_file_name}"  >  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/manpages"

# Create package
  
  cd "${base_folder}/${pack_name}/${pack_name}-${version}"
  debuild

 printf "List content in package\n"
dpkg -c ${base_folder}/${pack_name}/${pack_name}_${version}-1_all.deb


}

create_tar_ball() {
  rm -fr ${base_folder} || exit 1;

  mkdir -p ${base_folder}/${pack_name}/${pack_name}-${version};
  cd ${base_folder}/${pack_name}/${pack_name}-${version};

  mkdir scripts
  cp ${shell_file}  scripts ;
  chmod 755 scripts/${bash_file}; 

  mkdir man
  cp "${man_file}" man || $(File ${man_file} is missing; exit 3);

  cd ..
  tar -czf ${tar_boll} ${pack_name}-${version}
  rm -fr ${base_folder}/${pack_name}/${pack_name}-${version}
}

main "$@"


