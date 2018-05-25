virt_hypervisor__pkg_libvirt:
  pkg.installed:
{% set slsrequires =salt['pillar.get']('virt:slsrequires', False) %}
{% if slsrequires is defined and slsrequires %}
    - require:
{% for slsrequire in slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}
    - pkgs:
      - libvirt
      - libvirt-python
      - qemu-kvm-ev
      - qemu-kvm-tools-ev
{#
      - qemu-kvm-rhev
      - qemu-kvm-tools-rhev
      - libguestfs
      - libguestfs-tools 

virt_hypervisor__file_/etc/sysconfig/libvirtd:
  file.append:
    - name: /etc/sysconfig/libvirtd
    - require:
      - pkg: virt_hypervisor__pkg_libvirt
    - text: 
      - 'LIBVIRTD_ARGS="--listen"'
#}

{% set qemusecgroups = salt['pillar.get']('virt:qemusecgroups') %}
{% if qemusecgroups is defined and qemusecgroups %}
virt_hypervisor__user_qemu:
  user.present:
    - name: qemu
    - require:
      - pkg: virt_hypervisor__pkg_libvirt
    - watch_in:
      - service: virt_hypervisor__service_libvirt
    - remove_groups: False
    - groups: 
      {% for group in qemusecgroups -%}
      - {{ group }}
      {% endfor %}
{% endif %}

{% set hostid = salt['pillar.get']('virt:hostid') %}
{% if hostid is defined and hostid != '' %}
virt_hypervisor__file_/etc/libvirt/libvirtd.conf:
  augeas.change:
    - name: /etc/libvirt/libvirtd.conf
    - context: /files/etc/libvirt/libvirtd.conf
    - changes:
      - set host_uuid {{hostid}}
    - require:
      - pkg: virt_hypervisor__pkg_libvirt
    - watch_in:
      - service: virt_hypervisor__service_libvirt
{% endif %}

virt_hypervisor__service_libvirt:
  service.running:
    - name: libvirtd
    - require:
      - pkg: virt_hypervisor__pkg_libvirt
{#
    - watch:
      - file: virt_hypervisor__file_/etc/sysconfig/libvirtd
#}
