#! /bin/sh

version=$(head -5 meson.build | grep version | sed -e "s/[^']*'//" -e "s/'.*$//")
release_build_dir="release_build"
branch=$(git branch --show-current)

if [ -d ${release_build_dir} ]; then
  echo "Please remove ./${release_build_dir} first"
  exit 1
fi

# we include gtk-doc since we need the gtk-doc-for-gtk4 branch
meson setup --force-fallback-for gtk-doc ${release_build_dir} || exit

# make the release tarball
meson dist -C${release_build_dir} --include-subprojects || exit

# now build the docs
meson configure -Dgtk_doc=true ${release_build_dir} || exit
ninja -C${release_build_dir} pango-doc || exit

tar cf ${release_build_dir}/meson-dist/pango-docs-${version}.tar.xz ${release_build_dir}/docs/

echo -e "\n\nPango ${version} release on branch ${branch} in ./${release_build_dir}/:\n"

ls -l --sort=time -r "${release_build_dir}/meson-dist"

echo -e "\nPlease sanity-check these tarballs before uploading them."
