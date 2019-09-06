#!/bin/bash
#
# Create package for shell (No Makefile).
# 
set -x
set -e
declare -r SCRIPT=${0##*/}  || exit 201;  # SCRIPT is the name of this script
declare -r CDIR=$(dirname "$0")
declare -r DIR=$(pwd)

# Start editing here...
declare -r bash_file=my_shell_file
declare -r pack_name=my_pack_name
declare -r version=1.0.0
declare -r revision=1
declare -r new_man_file=${DIR}/man.1
declare -r DEBEMAIL="yourname@gmail.com"
declare -r DEBFULLNAME="your name"
declare -r Homepage=http:\/\/your_home_page.com
# ...Stop editing


declare -r templetes_dir=$(cd ../templates ; pwd );
declare -r target_dir=$(cd .. ; pwd)/target/;
declare -r base_folder=$(cd .. ; pwd)/target/;
declare -r shell_file=${DIR}/${bash_file}
declare -r man_file=${DIR}/man.1


export DEBEMAIL DEBFULLNAME

exit 0

# Init

declare tar_boll=${pack_name}-${version}.tar.gz  
declare -r temp_dir=$(mktemp -d)

main() {
  create_tar_ball;
  echo "Tar ball created:"
  ls -h ${base_folder}/${pack_name}/${tar_boll}

  echo "Untar ball"
  tar -xzmf ${base_folder}/${pack_name}/${tar_boll} -C ${base_folder}/${pack_name}
  cd ${base_folder}/${pack_name}/${pack_name}-${version}
# debmake -b':sh' -r ${revision}  -t -i debuild
  debmake -b':sh' -r ${revision}  

# Changelog
 sed -i -e 's/Initial release. Closes: #nnnn/Initial release./g'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
 sed -i -e '/is the bug number of your ITP/d'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
# sed -i -e 's/UNRELEASED/unstable/'  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/changelog"
 

# Copyright

 cp -f ${DIR}/copyright "${base_folder}/${pack_name}/${pack_name}-${version}/debian/"

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
   printf   man/market_test.1  >  "${base_folder}/${pack_name}/${pack_name}-${version}/debian/manpages"

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


