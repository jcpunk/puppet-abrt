## abrt module

This is the abrt module.
It can be used to maintain both the abrt daemon and libreport.

### Basic usage

Ensure that abrtd is running:
```puppet
class { 'abrt': }
```

Ensure that abrtd is not running:
```puppet
class { 'abrt':
  active => false,
}
```

### Dependencies

- stdlib (join)
- inifile (ini_setting)

### Configuration options

The abrt module supports all configuration options in the following files:
- abrt.conf
- abrt-action-save-package-data.conf

The defaults used are the Scientific Linux default values:
```puppet
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
```

Other variables allow to configure libreport:
- **abrt_mail**: Send notifications using mailx
- **abrt_mailx_to**: Specify who to send the reports to ('false' to enable defaults)
- **abrt_mailx_from**: Specify who should be appearing as the sender of reports ('false' to enable defaults)
- **abrt_mailx_binary**: Set the binary option for mailx ('false' to enable defaults)
- **abrt_mailx_detailed_subject**: Set a subject optimized for Puppet ('*fqdn* [*hostgroup*] abrt crash report for *program* [*package*]')
- **abrt_mailx_send_duplicate**: Send notification for duplicated events ([true]/false)
- **abrt_sosreport**: Generate sosreport ([true]/false)
- **abrt_backtrace**: Control backtrace generation, requires gdb ([false]/full/simple)
