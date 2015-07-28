{% for vmsprofile, vmsprofile_data in salt['pillar.get']('virt:vms:profiles',{}).items()|sort %}

{# set vmsprofile =salt['pillar.get']('virt:vms:profile', False) #}
{# if vmsprofile is defined and vmsprofile #}

virt_vms__libvirtxmls_vms_{{vmsprofile}}:
  file.recurse:
    - name: /etc/ceph/libvirt/vms/{{vmsprofile}}
    - clean: True
    - user: root
    - dir_mode: 0775
    - file_mode: '0644'
    - template: jinja
    - source: salt://files/libvirt/vms/{{vmsprofile}}

{% endfor %}

