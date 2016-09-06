{% from "virt/map.jinja" import virt with context %}

{% for vmsprofile, vmsprofile_data in virt.get('vms', {}).get('profiles',{}).items()|sort %}

virt_vms__libvirtxmls_vms_{{vmsprofile}}:
  file.recurse:
    - name: {{virt.vms.xmlfolder}}/{{vmsprofile}}
    - clean: True
    - user: root
    - dir_mode: 0775
    - file_mode: '0644'
    - template: jinja
    - source: salt://virt/files/xml/{{vmsprofile}}

{% endfor %}

