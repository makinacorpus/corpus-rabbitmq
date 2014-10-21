{% import "makina-states/services/queue/rabbitmq/init.sls" as macros with context %}
{% set users = {} %}
{% set rabbitmq = salt['mc_rabbitmq.settings']()%}
{% set cfg = opts.ms_project %}
{% set data = cfg.data %}
{% set db = cfg.data.db %}
include:
  - makina-states.services.queue.rabbitmq
apache2-utils:
  pkg.installed: []

