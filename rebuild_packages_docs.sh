# Copyright 2022 Balacoon
# build documentation for public Balacoon packages

# go to directory for documentation building
mkdir -p packages && pushd packages
for package in learn_to_pronounce learn_to_normalize ; do
  # clone if needed
  if [ ! -d ${package} ]; then
    git clone git@github.com:balacoon/${package}.git
  fi
  # go to package
  pushd ${package} && git pull
  # get submodules
  git submodule update --init --recursive
  pushd docs
  # build the documentation
  make html
  # put build documentation to api directory
  # that will be included into the website
  rm -rf ../../../packages_docs/${package} && mkdir -p ../../../packages_docs/${package}
  cp -r build/html/* ../../../packages_docs/${package}/
  # go to built documentation
  pushd ../../../packages_docs/${package}/
  # replace all underscores because they are ignored by jekyll
  for dirname in modules sources static; do
    grep -rl "_${dirname}/" . | xargs sed -i "s/_${dirname}\//${dirname}\//g"
    mv _${dirname} ${dirname}
  done
  js_script="sphinx_javascript_frameworks_compat.js"
  mv static/_${js_script} static/${js_script}
  grep -rl "_${js_script}" . | xargs sed -i "s/_${js_script}/${js_script}/g"
  # get out of packages_docs/${package_dir}
  popd
  # get out of packages/${package}/docs
  popd
  # get out of packages/${package}/
  popd
done
# get out of packages/
popd
