{% macro create_payment_type_dictionary() -%}
{% if target.type == 'clickhouse' -%}
{%- set ch_db = env_var('DWH_DB', target.schema) -%}
{%- set ch_user = env_var('DWH_USER', 'default') -%}
{%- set ch_password = env_var('DWH_PASSWORD', '') -%}
{%- set ch_host = env_var('CLICKHOUSE_HOST', 'localhost') -%}
{%- set ch_port = env_var('CLICKHOUSE_PORT_NATIVE', '9000') -%}

CREATE DICTIONARY IF NOT EXISTS {{ target.schema }}.payment_type_dict
(
    payment_type UInt64,
    description String
)
PRIMARY KEY payment_type
SOURCE(CLICKHOUSE(
    HOST '{{ ch_host }}'
    PORT {{ ch_port }}
    USER '{{ ch_user }}'
    PASSWORD '{{ ch_password }}'
    DB '{{ ch_db }}'
    TABLE 'payment_type_lookup'
))
LAYOUT(HASHED())
LIFETIME(MIN 0 MAX 0)
{%- else -%}
SELECT 1
{%- endif %}
{%- endmacro %}

{% macro create_taxi_zone_dictionary() -%}
{% if target.type == 'clickhouse' -%}
{%- set ch_db = env_var('DWH_DB', target.schema) -%}
{%- set ch_user = env_var('DWH_USER', 'default') -%}
{%- set ch_password = env_var('DWH_PASSWORD', '') -%}
{%- set ch_host = env_var('CLICKHOUSE_HOST', 'localhost') -%}
{%- set ch_port = env_var('CLICKHOUSE_PORT_NATIVE', '9000') -%}
CREATE DICTIONARY IF NOT EXISTS {{ target.schema }}.taxi_zone_dict
(
    locationid UInt64,
    borough String,
    zone String,
    service_zone String
)
PRIMARY KEY locationid
SOURCE(CLICKHOUSE(
    HOST '{{ ch_host }}'
    PORT {{ ch_port }}
    USER '{{ ch_user }}'
    PASSWORD '{{ ch_password }}'
    DB '{{ ch_db }}'
    TABLE 'taxi_zone_lookup'
))
LAYOUT(HASHED())
LIFETIME(MIN 0 MAX 0)
{%- else -%}
SELECT 1
{%- endif %}
{%- endmacro %}