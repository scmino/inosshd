inosshd
=======

Puppet module used to configure an OpenSSH server

Ensure OpenSSH daemon is present and running, with default configuration
(Typically directly called by the inospec module for zones where no configuration customization needs to be performed):

```
include inosshd
```

Ensure OpenSSH daemon is present and running and set default settings
(Typically directly called by the inospec module for zones where some configuration customization needs to be performed):

```
class { inosshd::default: settings => [
  'set X11Forwarding   no',
  'set PermitRootLogin no',
  'set <option>        <value>',
  ...
  ]
}
```

Ensure OpenSSH daemon is present and running and set custom settings
(Typically used by nodes requiring custom SSH options or to override options already set more globally):

```
class { inosshd::custom: settings => [
  'set ListenAddress   127.0.0.1',
  'set X11Forwarding   no',
  'set <option>        <value>',
  ...
  ]
}
```

For a list of available options, please see:

```
man 5 sshd_config
```

