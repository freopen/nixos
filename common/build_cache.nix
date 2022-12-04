{ pkgs, ... }: {
  system.activationScripts.build_cache = ''
    PATH="${pkgs.acl}/bin:$PATH"
    mkdir -p /var/cache/build
    setfacl -R -m d:g:wheel:rwx /var/cache/build
    setfacl -R -m g:wheel:rwx /var/cache/build
    setfacl -R -m d:g:nixbld:rwx /var/cache/build
    setfacl -R -m g:nixbld:rwx /var/cache/build
  '';
}
