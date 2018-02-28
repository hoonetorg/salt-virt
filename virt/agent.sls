{% from "virt/map.jinja" import virt with context %}

virt_agent__pkg_agent:
  pkg.installed:
    - pkgs: {{ virt.agent.pkgs|json }}
{% set slsrequires =salt['pillar.get']('virt:slsrequires', False) %}
{% if slsrequires is defined and slsrequires %}
    - require:
{% for slsrequire in slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}

virt_agent__service_agent:
  service.{{ virt.agent.service.state }}:
    - name: {{ virt.agent.service.name }}
{% if virt.agent.service.state in [ 'running', 'dead' ] %}
    - enable: {{ virt.agent.service.enable }}
{% endif %}
    - require:
      - pkg: virt_agent__pkg_agent
