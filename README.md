Module 'abrt'

Small module for configuring basic abrt configuration on Scientific Linux

Basic usage:
-----------

To ensure that abrtd is running:
 class { 'abrt': }

To ensure that abrtd is not running:
 class { 'abrt':
   active => false,
 }


Dependencies:
------------
- stdlib ('join' function)
- inifile (ini_setting)

Configuration options:
---------------------

The abrt module supports all configuration options in the following files:
- abrt.conf
- abrt-action-save-package-data.conf

The default used are the Scientific Linux default values:

  class { 'abrt':
    active => true,
    maxcrashreportssize => '1000',
    dumplocation => '/var/spool/abrt',
    deleteuploaded => 'no',
    opengpgcheck => 'yes',
    blacklist => ['nspluginwrapper', 'valgrind', 'strace', 'mono-core'],
    blacklistedpaths => ['/usr/share/doc/*', '*/example*', '/usr/bin/nspluginviewer', '/usr/lib/xulrunner-*/plugin-container'],
    processunpackaged => 'no',
  }
