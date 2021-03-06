# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import datagrip with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

{%- if datagrip.shortcut.install and grains.kernel|lower == 'linux' %}
    {%- set sls_package_install = tplroot ~ '.archive.install' %}

include:
  - {{ sls_package_install }}

datagrip-config-file-file-managed-desktop-shortcut_file:
  file.managed:
    - name: {{ datagrip.shortcut.file }}
    - source: {{ files_switch(['shortcut.desktop.jinja'],
                              lookup='datagrip-config-file-file-managed-desktop-shortcut_file'
                 )
              }}
    - mode: 644
    - user: {{ datagrip.identity.user }}
    - makedirs: True
    - template: jinja
    - context:
      command: {{ datagrip.command|json }}
                        {%- if grains.os == 'MacOS' %}
      edition: {{ '' if 'edition' not in datagrip else datagrip.edition|json }}
      appname: {{ datagrip.dir.path }}/{{ datagrip.pkg.name }}
                        {%- else %}
      edition: ''
      appname: {{ datagrip.dir.path }}
    - onlyif: test -f "{{ datagrip.dir.path }}/{{ datagrip.command }}"
                        {%- endif %}
    - require:
      - sls: {{ sls_package_install }}

{%- endif %}
