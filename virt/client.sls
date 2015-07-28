{#
virt_client__pkggroup_fonts:
  cmd.run:
    - name: yum -d 0 -e 0 -y group install fonts 
    - unless: yum -d 0 -e 0 -y  grouplist hidden installed id|grep "(fonts)"
{# dejavu-lgc-sans-fonts#}
#}

virt_client__pkg_libvirt:
  pkg.installed:
    - name: libvirt
    - pkgs:
      - virt-install
      - virt-manager
      - virt-viewer
      - virt-top
      - xorg-x11-xauth
      - dbus-x11
      - dconf
      - dejavu-lgc-sans-fonts
      - gnome-icon-theme
{% set slsrequires =salt['pillar.get']('virt:slsrequires', False) %}
{% if slsrequires is defined and slsrequires %}
    - require:
{% for slsrequire in slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}
{#
      - cmd: virt_client__pkggroup_fonts
      - libguestfs
      - libguestfs-tools 
#}

virt_client__pkggroup_update_mime:
  cmd.wait:
    - name: update-mime-database -V /usr/share/mime
    - watch:
      - pkg: virt_client__pkg_libvirt

