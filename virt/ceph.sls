{% from "virt/map.jinja" import virt with context %}

virt_ceph__file_/etc/ceph:
  file.directory:
    - name: /etc/ceph
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{% set cluster = salt['pillar.get']('cephname', "ceph") -%}
{% if cluster != '' %}
{% set cluster_data = salt['pillar.get']('virt:ceph:clusters:' + cluster ,{}) -%}

{% for secret, secret_data in cluster_data.secrets.items()|sort %}

virt_ceph__file_/etc/ceph/{{cluster}}.client.{{secret}}.xml:
  file.managed:
    - name: /etc/ceph/{{cluster}}.client.{{secret}}.xml
    - contents: |
        <secret ephemeral='no' private='no'>
          <uuid>{{secret_data.secretuuid}}</uuid>
          <usage type='ceph'>
            <name>{{cluster}}.client.{{secret}} secret</name>
          </usage>
        </secret>

    - require:
      - file: virt_ceph__file_/etc/ceph

virt_ceph__libvirt_secret_define_{{cluster}}_{{secret}}:
  cmd.run:
    - name: virsh secret-define /etc/ceph/{{cluster}}.client.{{secret}}.xml
    - unless: virsh secret-list |egrep "^[[:blank:]]*{{secret_data.secretuuid}}[[:blank:]]+"
    - require:
      - file: virt_ceph__file_/etc/ceph/{{cluster}}.client.{{secret}}.xml

virt_ceph__libvirt_secret_set_value_{{cluster}}_{{secret}}:
  cmd.run:
    - name: virsh secret-set-value --secret {{secret_data.secretuuid}} --base64 $(ceph --cluster {{cluster}} auth get-key client.{{secret}})
    - unless: test -n "$(virsh secret-get-value {{secret_data.secretuuid}} 2>/dev/null)" -a "$(virsh secret-get-value {{secret_data.secretuuid}} 2>/dev/null)" == "$(ceph --cluster {{cluster}} auth get-key client.{{secret}} 2>/dev/null)" 
    - require:
      - cmd: virt_ceph__libvirt_secret_define_{{cluster}}_{{secret}}

{% endfor %}

{% for pool, pool_data in cluster_data.pools.items()|sort %}
{% set secret = pool_data.secret %}
{% if pool_data.autostart is defined and pool_data.autostart %}
{% set autostart = pool_data.autostart %}
{% else %}
{% set autostart = False %}
{% endif %}
{% set secretuuid =  salt['pillar.get']('virt:ceph:clusters:' + cluster + ':secrets:' + secret + ':secretuuid', False) -%}
{# set cluster_ceph_data = salt['pillar.get']('ceph:lookup:clusters:' + cluster ,{}) -#}

virt_ceph__file_/etc/ceph/pool-{{cluster}}-{{pool}}.xml:
  file.managed:
    - name: /etc/ceph/pool-{{cluster}}-{{pool}}.xml
    - contents: |
        <pool type='rbd'>
          <name>{{pool}}</name>
          <source>
{% for mon in cluster_data.mons|sort %}
            <host name='{{mon}}' port='6789'/>
{% endfor %}
            <name>{{pool}}</name>
            <auth type='ceph' username='{{secret}}'>
              <secret uuid='{{secretuuid}}'/>
            </auth>
          </source>
        </pool>

    - require:
      - file: virt_ceph__file_/etc/ceph

virt_ceph__libvirt_pool_define_{{cluster}}_{{pool}}:
  cmd.run:
    - name: virsh pool-define /etc/ceph/pool-{{cluster}}-{{pool}}.xml
    - unless: virsh pool-list --all |egrep "^[[:blank:]]*{{pool}}[[:blank:]]+"
    - require:
      - file: virt_ceph__file_/etc/ceph/pool-{{cluster}}-{{pool}}.xml
      - cmd: virt_ceph__libvirt_secret_define_{{cluster}}_{{secret}}
      - cmd: virt_ceph__libvirt_secret_set_value_{{cluster}}_{{secret}}

{% if autostart %}

virt_ceph__libvirt_pool_start_{{cluster}}_{{pool}}:
  cmd.run:
    - name: virsh pool-start {{pool}} 
    - unless: virsh pool-list |egrep "^[[:blank:]]*{{pool}}[[:blank:]]+"
    - require:
      - cmd: virt_ceph__libvirt_pool_define_{{cluster}}_{{pool}}
      - cmd: virt_ceph__libvirt_secret_set_value_{{cluster}}_{{secret}}

virt_ceph__libvirt_pool_autostart_{{cluster}}_{{pool}}:
  cmd.run:
    - name: virsh pool-autostart {{pool}} 
    - unless: virsh pool-list --autostart --all |egrep "^[[:blank:]]*{{pool}}[[:blank:]]+"
    - require:
      - cmd: virt_ceph__libvirt_pool_define_{{cluster}}_{{pool}}
      - cmd: virt_ceph__libvirt_secret_set_value_{{cluster}}_{{secret}}

{% endif %}

{% endfor %}

{% endif %}

