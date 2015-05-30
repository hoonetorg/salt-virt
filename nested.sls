virt_nested__file_/etc/modprobe.d:
  file.directory:
    - name: /etc/modprobe.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

virt_nested__file_/etc/modprobe.d/kvm-intel.conf:
  file.managed:
    - name: /etc/modprobe.d/kvm-intel.conf
    - contents_newline: True
    - contents: |
        options kvm-intel nested=1

    - require:
      - file: virt_nested__file_/etc/modprobe.d

virt_nested__file_/etc/modprobe.d/kvm-amd.conf:
  file.managed:
    - name: /etc/modprobe.d/kvm-amd.conf
    - contents_newline: True
    - contents: |
        options kvm-amd nested=1

    - require:
      - file: virt_nested__file_/etc/modprobe.d

