class stack_logstash::kibana (
  $version                   = '3.1.2',
  $kibana_url                = "kibana.${::domain}",
  $config_template           = 'stack_logstash/kibana/config.js.erb',
  $options_hash              = { },
  $webserver                 = 'nginx',
  $webserver_config_template = undef,
  ) {

  $default_options = {
    'elasticsearch'          => 'http://"+window.location.hostname+":9200',
    'default_route'          => '/dashboard/file/logstash.json',
    'kibana_index'           => 'kibana-int',
    'panel_names'            => "[ 'histogram','map','goal','table','filtering','timepicker','next','hits','column','trends','bettermap','query','terms','stats','sparklines' ]",
  }
  $options=merge($default_options , $options_hash)

  # TODO Install Kibana via TP
  $real_webserver_config_template = $webserver_config_template ? {
    undef    => "stack_logstash/kibana/kibana.conf-${webserver}",
    default  => $webserver_config_template,
  }
  class { '::kibana':
    version           => $version,
    file_template     => $config_template,
    file_options_hash => $options,
  }

  if $webserver
  and $webserver != '' {
    tp::install { $webserver: }
    tp::conf { "${webserver}::conf.d/kibana.conf":
      template => $real_webserver_config_template,
    }
  }
}
