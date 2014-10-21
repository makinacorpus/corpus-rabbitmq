{% import "makina-states/services/queue/rabbitmq/init.sls" as macros with context %}
{% set users = {} %}
{% set rabbitmq = salt['mc_rabbitmq.settings']()%}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set db = cfg.data.db %}
include:
  - makina-states.services.queue.rabbitmq
apache2-utils:
    pkg.installed

{% for dbext in data.vhosts %}
{% for db, dbdata in dbext.items() %}
{{ macros.rabbitmq_vhost(db, user=dbdata.user, password=dbdata.password) }}
{% do users.update({dbdata.user: {'password': dbdata.password}}) %}
{%endfor %}
{%endfor%}

{% do users.update({rabbitmq.rabbitmq.admin: {'password': rabbitmq.rabbitmq.password}}) %}
{% set userdatas = data.get('users', []) %}
{% do userdatas.append(users) %}

{{cfg.name}}-htaccess:
  file.managed:
    - name: {{data.htaccess}}
    - source: ''
    - user: www-data
    - group: www-data
    - mode: 770

{% for userdict in userdatas %}
{% for user, ddata in userdict.items() %}
{% set ddata = ddata.copy() %}
{% set pw = ddata.pop('password', '') %}
{% set s = ddata.setdefault('state_uid', 'corpus'+cfg.name) %}
{{macros.rabbitmq_user(user, pw, **ddata) }}
{{cfg.name}}-{{user}}-htaccess:
  webutil.user_exists:
    - name: {{user}}
    - password: {{pw}}
    - htpasswd_file: {{data.htaccess}}
    - options: m
    - force: true
    - watch:
      - file: {{cfg.name}}-htaccess
{% endfor %}
{% endfor %}
