class abrt (
    $active = true,
    $detailedmailsubject = false,
    $maxcrashreportssize = '1000',
    $dumplocation = '/var/spool/abrt',
    $deleteuploaded = 'no',
    $opengpgcheck = 'yes',
    $blacklist = ['nspluginwrapper', 'valgrind', 'strace', 'mono-core'],
    $blacklistedpaths = ['/usr/share/doc/*', '*/example*', '/usr/bin/nspluginviewer', '/usr/lib/xulrunner-*/plugin-container'],
    $processunpackaged = 'no',
    $abrt_mailx_to = false,
    $abrt_mailx_from = false,
    $abrt_mailx_binary = false,
    $abrt_sosreport = true
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

  if ($detailedmailsubject) {
    file { '/etc/libreport/events.d/abrt_event.conf':
      ensure => present,
      owner   => root,
      group   => root,
      content => template("${module_name}/abrt_event.conf.erb"),
      require => Package['abrt'],
      notify => Service["abrtd"],
    }
  }
}
