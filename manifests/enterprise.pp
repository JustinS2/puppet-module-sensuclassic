# @summary Installs the Sensu packages
#
# Installs Sensu enterprise
#
# @param deregister_handler The handler to use when deregistering a client on stop.
#
# @param deregister_on_stop Whether the sensu client should deregister from the API on service stop
#
# @param gem_path Paths to add to GEM_PATH if we need to look for different dirs.
#
# @param init_stop_max_wait Number of seconds to wait for the init stop script to run
#
# @param log_dir Sensu log directory to be used
#   Valid values: Any valid log directory path, accessible by the sensu user
#
# @param log_level Sensu log level to be used
#   Valid values: debug, info, warn, error, fatal
#
# @param path Used to set PATH in /etc/default/sensu
#
# @param rubyopt Ruby opts to be passed to the sensu services
#
# @param use_embedded_ruby If the embedded ruby should be used, e.g. to install the
#   sensu-plugin gem. This value is overridden by a defined
#   sensu_plugin_provider. Note, the embedded ruby should always be used to
#   provide full compatibility. Using other ruby runtimes, e.g. the system
#   ruby, is not recommended.
#
# @param heap_size Value of the HEAP_SIZE environment variable.
#
# @param max_open_files Value of the MAX_OPEN_FILES environment variable.
#
# @param heap_dump_path Value of the HEAP_DUMP_PATH environment variable.
#
# @param java_opts Value of the JAVA_OPTS environment variable.
#
class sensuclassic::enterprise (
  Optional[String] $deregister_handler = $sensuclassic::deregister_handler,
  Optional[Boolean] $deregister_on_stop = $sensuclassic::deregister_on_stop,
  Optional[String] $gem_path = $sensuclassic::gem_path,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $init_stop_max_wait = $sensuclassic::init_stop_max_wait,
  Optional[String] $log_dir = $sensuclassic::log_dir,
  Optional[String] $log_level = $sensuclassic::log_level,
  Optional[String] $path = $sensuclassic::path,
  Optional[String] $rubyopt = $sensuclassic::rubyopt,
  Optional[Boolean] $use_embedded_ruby = $sensuclassic::use_embedded_ruby,
  Variant[Undef,Integer,Pattern[/^(\d+)/]] $heap_size = $sensuclassic::heap_size,
  Variant[Undef,Integer,Pattern[/^(\d+)$/]] $max_open_files = $sensuclassic::max_open_files,
  Variant[Undef,String] $heap_dump_path = $sensuclassic::heap_dump_path,
  Variant[Undef,String] $java_opts = $sensuclassic::java_opts,
  Boolean $hasrestart = $sensuclassic::hasrestart,
) {

  # Package
  if $sensuclassic::enterprise {

    package { 'sensu-enterprise':
      ensure  => $sensuclassic::enterprise_version,
    }

    file { '/etc/default/sensu-enterprise':
      ensure  => file,
      content => template("${module_name}/sensu-enterprise.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0444',
      require => Package['sensu-enterprise'],
    }
  }

  # Service
  if $sensuclassic::manage_services and $sensuclassic::enterprise {

    case $sensuclassic::enterprise {
      true: {
        $ensure = 'running'
        $enable = true
      }
      default: {
        $ensure = 'stopped'
        $enable = false
      }
    }

    if $::osfamily != 'windows' {
      service { 'sensu-enterprise':
        ensure     => $ensure,
        enable     => $enable,
        hasrestart => $hasrestart,
        subscribe  => [
          File['/etc/default/sensu-enterprise'],
          Sensuclassic_api_config[$::fqdn],
          Class['sensuclassic::redis::config'],
          Class['sensuclassic::rabbitmq::config'],
          Class['sensuclassic::package'],
        ],
      }
    }
  }
}
