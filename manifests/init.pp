class abrt (
    $active = true,
    $maxcrashreportssize = '1000',
    $dumplocation = '/var/spool/abrt',
    $deleteuploaded = 'no',
    $opengpgcheck = 'yes',
    $blacklist = ['nspluginwrapper', 'valgrind', 'strace', 'mono-core'],
    $blacklistedpaths = ['/usr/share/doc/*', '*/example*', '/usr/bin/nspluginviewer', '/usr/lib/xulrunner-*/plugin-container'],
    $processunpackaged = 'no',
  ) {

  # Install Package
  package { 'abrt':
    ensure => present,
  }

  # Have service running (or not)
  if ($active) {
    service { ['abrtd','abrt-oops','abrt-ccpp']:
      ensure => running,
      enable => true,
      require => Package['abrt'],
    }
  } else {
    service { ['abrtd','abrt-oops','abrt-ccpp']:
      ensure => stopped,
      enable => false,
      require => Package['abrt'],
    }
  }

  # /etc/abrt/abrt.conf
  ## DumpLocation
  ini_setting { "abrt_DumpLocation":
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'DumpLocation',
    value   => $dumplocation,
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ## MaxCrashReportsSize
  ini_setting { "abrt_MaxCrashReportsSize":
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'MaxCrashReportsSize',
    value   => $maxcrashreportssize,
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ## DeleteUploaded
  ini_setting { "abrt_DeleteUploaded":
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'DeleteUploaded',
    value   => $deleteuploaded,
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  # abrt-action-save-package-data.conf
  ##
  ini_setting { "abrt_OpenGPGCheck":
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'OpenGPGCheck',
    value   => $opengpgcheck,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { "abrt_BlackList":
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'BlackList',
    value   => join($blacklist, ', '),
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { "abrt_BlackListedPaths":
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'BlackListedPaths',
    value   => join($blacklistedpaths, ', '),
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { "abrt_ProcessUnpackaged":
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'ProcessUnpackaged',
    value   => $processunpackaged,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

}
