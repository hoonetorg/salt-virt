# -*- coding: utf-8 -*-
# vim: ft=sls
{%- from "virt/map.jinja" import virt with context %}

{% set pcs = virt.get('pcs', {}) %}

{% if pcs.virt_cib is defined and pcs.virt_cib %}
virt_pcs__cib_present_{{pcs.virt_cib}}:
  pcs.cib_present:
    - cibname: {{pcs.virt_cib}}
{% endif %}

{% if 'resources' in pcs %}
{% for resource, resource_data in pcs.resources.items()|sort %}
virt_pcs__resource_present_{{resource}}:
  pcs.resource_present:
    - resource_id: {{resource}}
    - resource_type: "{{resource_data.resource_type}}"
    - resource_options: {{resource_data.resource_options|json}}
{% if pcs.virt_cib is defined and pcs.virt_cib %}
    - require:
      - pcs: virt_pcs__cib_present_{{pcs.virt_cib}}
    - require_in:
      - pcs: virt_pcs__cib_pushed_{{pcs.virt_cib}}
    - cibname: {{pcs.virt_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if 'constraints' in pcs %}
{% for constraint, constraint_data in pcs.constraints.items()|sort %}
virt_pcs__constraint_present_{{constraint}}:
  pcs.constraint_present:
    - constraint_id: {{constraint}}
    - constraint_type: "{{constraint_data.constraint_type}}"
    - constraint_options: {{constraint_data.constraint_options|json}}
{% if pcs.virt_cib is defined and pcs.virt_cib %}
    - require:
      - pcs: virt_pcs__cib_present_{{pcs.virt_cib}}
    - require_in:
      - pcs: virt_pcs__cib_pushed_{{pcs.virt_cib}}
    - cibname: {{pcs.virt_cib}}
{% endif %}
{% endfor %}
{% endif %}

{% if pcs.virt_cib is defined and pcs.virt_cib %}
virt_pcs__cib_pushed_{{pcs.virt_cib}}:
  pcs.cib_pushed:
    - cibname: {{pcs.virt_cib}}
{% endif %}

virt_pcs__empty_sls_prevent_error:
  cmd.run:
    - name: "true"
    - unless: "true"
