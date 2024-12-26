node default {
  include apache_site
  include grafana
  
  class { 'prometheus':
  include prometheus::node_exporter
  manage_prometheus_server => true,
  version                  => '2.52.0',
  alerts                   => {
    'groups' => [
      {
        'name'  => 'alert.rules',
        'rules' => [
          {
            'alert'       => 'InstanceDown',
            'expr'        => 'up == 0',
            'for'         => '5m',
            'labels'      => {'severity' => 'page'},
            'annotations' => {
              'summary'     => 'Instance {{ $labels.instance }} down',
              'description' => '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.'
            },
          },
        ],
      },
    ],
  },
  scrape_configs           => [
    {
      'job_name'        => 'node_exporter',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9100'],
          'labels'  => {'alias' => 'Node'}
        },
      ],
    },
    {
      'job_name'        => 'apache_exporter',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9117'],
          'labels'  => {'alias' => 'Apache'}
        },
      ],
    },
    {
      'job_name'        => 'mysqld_exporter',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9104'],
          'labels'  => {'alias' => 'MySQL'}
        },
      ],
    },
    {
      'job_name'        => 'statsd_exporter',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9102'],
          'labels'  => {'alias' => 'STATSD'}
        },
      ],
    },
    {
      'job_name'        => 'collectd_exporter',
      'scrape_interval' => '5s',
      'scrape_timeout'  => '5s',
      'static_configs'  => [
        {
          'targets' => ['localhost:9103'],
          'labels'  => {'alias' => 'COLLECD'}
        },
      ],
    },
  ],
  alertmanagers_config     => [
    {
      'static_configs' => [{'targets' => ['localhost:9093']}],
    },
  ],
  }

  class { 'prometheus::alertmanager':
  version   => '0.27.0',
  route     => {
    'group_by'        => ['alertname', 'cluster', 'service'],
    'group_wait'      => '30s',
    'group_interval'  => '5m',
    'repeat_interval' => '3h',
    'receiver'        => 'email',
  },
  receivers => [
    {
      'name'          => 'email',
      'email_configs' => [
        {
          'to'       => 'root@localhost',
        },
      ],
    },
  ],
  }
}

