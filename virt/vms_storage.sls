{% from "virt/map.jinja" import virt with context %}

{% for vmsprofile, vmsprofile_data in virt.get('vms', {}).get('profiles',{}).items()|sort %}

  {% for disk, disk_data in vmsprofile_data.get('disks', {}).items()|sort %}

    {% if disk_data.get('method', 'create') in  [ 'create' ] %}
virt_vms_storage__create_disk_{{vmsprofile}}_{{disk}}:
  cmd.run:
    - name: qemu-img create -f {{ disk_data.get('format', 'raw') }} {{disk}} {{disk_data.size}}
    - unless: qemu-img info {{disk}}

    {% elif disk_data.get('method', 'create') in  [ 'convert' ] %}
virt_vms_storage__convert_disk_{{vmsprofile}}_{{disk}}:
  cmd.run:
    - name: qemu-img convert -f {{disk_data.get('sourcefmt', 'raw')}} -O {{ disk_data.get('format', 'raw') }} {{disk_data.get('source')}} {{disk}}

      {% if disk_data.get('check_method', 'drbd') in [ 'qemu-img' ] %}
    - unless: qemu-img info {{disk}}

      {% elif disk_data.get('check_method', 'drbd') in [ 'blkid' ] %}
    - onlyif: test -b {{disk}} && test -w {{disk}}
    - unless: blkid -c /dev/null {{disk}}

      {% else %}
      {% set drbd_resource = disk|regex_search('^.*/dev/drbd/by-res/(.*)/[0-9]+\s*$') %}
    - onlyif: test -b {{disk}} && test -w {{disk}} && drbdadm role {{ drbd_resource[0] }}|grep Secondary
    - unless: '! dd if={{disk}} of=/dev/null bs=1 count=1 || blkid -c /dev/null {{disk}}'
      {% endif %}

      {% if disk_data.get('size', False) %}
virt_vms_storage__resize_disk_{{vmsprofile}}_{{disk}}:
  cmd.wait:
    - name: qemu-img resize -f {{ disk_data.get('format', 'raw') }} {{disk}} {{disk_data.size}}
    - watch:
      - cmd: virt_vms_storage__convert_disk_{{vmsprofile}}_{{disk}}
      {% endif %}

    {% endif %}

  {% endfor %}

{% endfor %}



