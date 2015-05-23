virt_keys__keys_libvirt:
  libvirt.keys:
{% set slsrequires =salt['pillar.get']('virt:slsrequires', False) %}
{% if slsrequires is defined and slsrequires %}
    - require:
{% for slsrequire in slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}

