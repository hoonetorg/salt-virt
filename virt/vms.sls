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

  {% for image, image_data in vmsprofile_data.get('images', {}).items() %}

    {% if image_data.get('method', 'rsync') in  [ 'rsync' ] %}
virt_vms__libvirt_images_{{vmsprofile}}_{{image}}:
  rsync.synchronized:
    - name: {{virt.vms.imagesfolder}}/{{vmsprofile}}
    - source: {{image_data.source}}
    - prepare: True

    {% elif image_data.get('method', 'rsync') in  [ 'url' ] %}
virt_vms__libvirt_images_{{vmsprofile}}_{{image}}:
  file.managed:
    - name: {{virt.vms.imagesfolder}}/{{vmsprofile}}/{{image}}
    - source: {{image_data.source}}
      {% if image_data.get('source_hash', False ) %}
    - source_hash: {{image_data.source_hash}}
      {% endif %}
    - makedirs: True
    - user: root
    - group: root
    - mode: "0644"

    {% endif %}

  {% endfor %}

{% endfor %}
