# @summary Manages Sensu filters
#
# Defines Sensu filters
#
# @param ensure Whether the check should be present or not
#
# @param negate Negate the filter
#
# @param attributes Hash of attributes for the filter
#
# @param when Hash of when entries for the filter
#
define sensuclassic::filter (
  Enum['present','absent'] $ensure = 'present',
  Optional[Boolean] $negate = undef,
  Optional[Hash] $attributes = undef,
  Optional[Hash] $when = undef,
) {

  include sensuclassic

  file { "${sensuclassic::conf_dir}/filters/${name}.json":
    ensure => $ensure,
    owner  => $sensuclassic::user,
    group  => $sensuclassic::group,
    mode   => '0444',
  }

  sensuclassic_filter { $name:
    ensure     => $ensure,
    negate     => $negate,
    attributes => $attributes,
    when       => $when,
    require    => File["${sensuclassic::conf_dir}/filters"],
  }
}
