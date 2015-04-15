# == Class: abrt
#
# This class installs abrt (https://github.com/abrt/abrt/wiki/ABRT-Project) and manage it's configuration
#
# === Requirements/Dependencies
#
# Requires the puppetlabs/stdlib module for the 'ensure_packages' function
#
# === Parameters
#
# [*active*]
#   Boolean controling the abrtd service and its dependencies.
#   If set to true (default), these services run, otherwise they are stopped and disactivated
#
# [*abrt_mail*]
#   Boolean controling the email notifications.
#   If set to true (default), emails will be sent to $abrt_mailx_to, otherwise, nothing will happen
#
# [*detailedmailsubject*]
#   *DEPRECATED* this option was replaced by abrt_mailx_detailed_subject (see below)
#
# [*maxcrashreportssize*]
#   Controls the MaxCrashReportsSize option in abrt.conf (integer):
#   > The maximum disk space (specified in megabytes) that 'abrt'
#   > will use for all the crash dumps. Specify a value here to ensure
#   > that the crash dumps will not fill all available storage space.
#   > The default is 1000.
#
# [*dumplocation*]
#   Controls the DumpLocation option in abrt.conf (path):
#   > The directory where should 'abrt' store coredumps and all files which are
#   > needed for reporting. The default is /var/spool/abrt.
#
# [*deleteuploaded*]
#   Controls the DeleteUploaded option in abrt.conf (yes/no):
#   > The daemon will delete an uploaded crashdump archive after an atempt to
#   > unpack it. An archive will be delete whether unpacking finishes successfully
#   > or not.
#   > The default value is 'no'.
#
# [*opengpgcheck*]
#   Controls the OpenGPGCheck option in abrt-action-save-package-data.conf (yes/no):
#   > When set to 'yes', 'abrt' will handle only crashes in executables which belong
#   > to an installed package with valid GPG signature.
#   > The default is 'yes'.
#   > The files containing trusted GPG keys which are used to verify
#   > the signatures are listed in the gpg_keys.conf configuration file.
#
# [*blacklist*]
#   Controls the BlackList option in abrt-action-save-package-data.conf (list):
#   > 'abrt' will ignore packages in this list and will not handle their crashes.
#
# [*blacklistedpaths*]
#   Controls the BlackListedPaths option in abrt-action-save-package-data.conf (list):
#   > 'abrt' will ignore crashes in executables whose absolute path matches
#   > one of specified patterns.
#
# [*processunpackaged*]
#   Controls the ProcessUnpackaged option in abrt-action-save-package-data.conf (yes/no):
#   > When set to 'yes', 'abrt' will catch all crashes in the system.
#   > When set to 'no', it will catch crashes only in executables which belong
#   > to an installed package.
#   > The default is 'no'.
#
# [*abrt_mailx_to*]
#   Email address to which crash notification are sent
#
# [*abrt_mailx_from*]
#   Email address from which crash notification are sent
#
# [*abrt_mailx_binary*]
#   Controls the SendBinaryData option for libreport:
#   > Use yes/true/on/1 to attach all binary files from the problem
#   > directory to the email. This can cause the emails to be very
#   > large.
#
# [*abrt_mailx_detailed_subject*]
#  Set a subject optimized for Puppet:
#  > *fqdn* [*hostgroup*] abrt crash report for *program* [*package*]'
#
# [*abrt_mailx_send_duplicate*]
#   Controls the notification of duplicated crashes (true/false).
#   If set to true, an email will be sent for every occurence (modulo abrt limits).
#   If set to false, only the first event will result in a notification
#
# [*abrt_sosreport*]
#   Controls the generation of an 'sosreport' using sosreport (true/false).
#
# [*abrt_backtrace*]
#   Controls the generation of the backtrace for 'CCpp' crashes (false/simple/full):
#    - If set to false, no backtrace will be generated
#    - If set to simple, gdb will be used to generate a backtrace
#    - If set to full, abrt-action-generate-backtrace will be used to generate a backtrace
#
# === Examples
#
# Installing and running abrt with mail optimisations for all crashes, except duplicates:
#
# class { 'abrt':
#   abrt_mailx_from             => "root@${fqdn}",
#   abrt_mailx_detailed_subject => true,
#   opengpgcheck                => 'no',
#   processunpackaged           => 'yes',
#   maxcrashreportssize         => '0',
#   abrt_mailx_send_duplicate   => false
# }
#
class abrt (
    $active = true,
    $abrt_mail = true,
    $detailedmailsubject = false,  # Obsolete
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
    $abrt_mailx_detailed_subject = false,
    $abrt_mailx_send_duplicate = true,
    $abrt_sosreport = true,
    $abrt_backtrace = false    # or "full", or "simple"
  ) {

  # Install Packages
  ensure_packages(['abrt',
    'abrt-addon-ccpp',
    'abrt-addon-kerneloops',
    'abrt-addon-python',
    ])
  if ($abrt_mail) {
    ensure_packages(['libreport-plugin-mailx'])
  }

  # Have service running (or not)
  if ($active) {
    service { ['abrtd','abrt-oops','abrt-ccpp']:
      ensure  => running,
      enable  => true,
      require => [Package['abrt'], Package['abrt-addon-ccpp'], Package['abrt-addon-kerneloops']],
    }
    Service['abrtd'] -> Service['abrt-oops']
    Service['abrtd'] -> Service['abrt-ccpp']
  } else {
    service { ['abrtd','abrt-oops','abrt-ccpp']:
      ensure  => stopped,
      enable  => false,
      require => [Package['abrt'], Package['abrt-addon-ccpp'], Package['abrt-addon-kerneloops']],
    }
  }

  # /etc/abrt/abrt.conf
  ## DumpLocation
  ini_setting { 'abrt_DumpLocation':
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'DumpLocation',
    value   => $dumplocation,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ## MaxCrashReportsSize
  ini_setting { 'abrt_MaxCrashReportsSize':
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'MaxCrashReportsSize',
    value   => $maxcrashreportssize,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ## DeleteUploaded
  ini_setting { 'abrt_DeleteUploaded':
    path    => '/etc/abrt/abrt.conf',
    section => '',
    setting => 'DeleteUploaded',
    value   => $deleteuploaded,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  # abrt-action-save-package-data.conf
  ##
  ini_setting { 'abrt_OpenGPGCheck':
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'OpenGPGCheck',
    value   => $opengpgcheck,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { 'abrt_BlackList':
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'BlackList',
    value   => join($blacklist, ', '),
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { 'abrt_BlackListedPaths':
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'BlackListedPaths',
    value   => join($blacklistedpaths, ', '),
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  ini_setting { 'abrt_ProcessUnpackaged':
    path    => '/etc/abrt/abrt-action-save-package-data.conf',
    section => '',
    setting => 'ProcessUnpackaged',
    value   => $processunpackaged,
    require => Package['abrt'],
    notify  => [Service['abrtd'], Service['abrt-oops'], Service['abrt-ccpp']]
  }

  file { '/etc/libreport/events.d/abrt_event.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("${module_name}/abrt_event.conf.erb"),
    require => Package['abrt'],
    notify  => Service['abrtd'],
  }

  if ($abrt_mail) {
    $libreport_mail_requirement = [Package['abrt'], Package['libreport-plugin-mailx']]
  } else {
    $libreport_mail_requirement = Package['abrt']
  }

  file { '/etc/libreport/events.d/mailx_event.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("${module_name}/mailx_event.conf.erb"),
    require => $libreport_mail_requirement,
    notify  => Service['abrtd'],
  }

  file { '/etc/libreport/plugins/mailx.conf':
    ensure  => present,
    owner   => root,
    group   => root,
    content => template("${module_name}/mailx.conf.erb"),
    require => $libreport_mail_requirement,
    notify  => Service['abrtd'],
  }
}
