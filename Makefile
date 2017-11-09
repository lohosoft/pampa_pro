PROJECT = pampa_pro
PROJECT_DESCRIPTION = New project
PROJECT_VERSION = 0.1.0

DEPS = cowboy sync amqp_client ranch
dep_cowboy_commit = master
DEP_PLUGINS = cowboy

include erlang.mk
