# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import datagrip with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

    {%- if datagrip.pkg.use_upstream_macapp %}
        {%- set sls_package_install = tplroot ~ '.macapp.install' %}
    {%- else %}
        {%- set sls_package_install = tplroot ~ '.archive.install' %}
    {%- endif %}

include:
  - {{ sls_package_install }}

datagrip-config-file-file-managed-environ_file:
  file.managed:
    - name: {{ datagrip.environ_file }}
    - source: {{ files_switch(['environ.sh.jinja'],
                              lookup='datagrip-config-file-file-managed-environ_file'
                 )
              }}
    - mode: 644
    - user: {{ datagrip.identity.rootuser }}
    - group: {{ datagrip.identity.rootgroup }}
    - makedirs: True
    - template: jinja
    - context:
              {%- if datagrip.pkg.use_upstream_macapp %}
        path: '/Applications/{{ datagrip.pkg.name }}{{ '\ %sE'|format(datagrip.edition) }}.app/Contents/MacOS'
              {%- else %}
        path: {{ datagrip.pkg.archive.path }}/bin
              {%- endif %}
        environ: {{ datagrip.environ|json }}
    - require:
      - sls: {{ sls_package_install }}