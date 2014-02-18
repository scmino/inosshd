  /*
  *  This module configures the OpenSSH daemon on the server
  *
  *  Ensure OpenSSH daemon is present and running, with default configuration
  *    => Typically directly called by the inospec module for zones where no
  *       configuration customization needs to be performed)
  *
  *  include inosshd
  *
  *  Ensure OpenSSH daemon is present and running and set default settings
  *    => Typically directly called by the inospec module for zones where some
  *       configuration customization needs to be performed
  *
  *  class { inosshd::default: settings => [
  *      'set X11Forwarding   no',
  *      'set PermitRootLogin no',
  *      'set <option>        <value>',
  *      ...
  *    ]
  *  }
  *
  *  Ensure OpenSSH daemon is present and running and set custom settings
  *    => Typically used by nodes requiring custom SSH options
  *    => Can be used to override options already set more globally
  *
  *  class { inosshd::custom: settings => [
  *      'set ListenAddress   127.0.0.1',
  *      'set X11Forwarding   no',
  *      'set <option>        <value>',
  *      ...
  *    ]
  *  }
  *
  *  For a list of available options, please see:
  *  man 5 sshd_config
  */

#
# Specific class used to set default configuration options
# (typically directly called by the inospec module)
#
class inosshd::default($settings) inherits inosshd {

  # Call build_config with default options
  Inosshd::Build_config['default'] { default_settings => $settings }

}

#
# Specific class used to set customized configuration options
# (typically called in site.pp for nodes requiring custom SSH configuration)
#
class inosshd::custom($settings) inherits inosshd {

  # Call build_config with custom options
  Inosshd::Build_config['default'] { custom_settings => $settings }

}

#
# Main class
#
class inosshd {

  define build_config($default_settings, $custom_settings) {

    # Define groups depending on the OS
    $sshsrv = $::osfamily ? {
      RedHat  => 'sshd',
      Debian  => 'ssh',
      default => undef,
    }

    if $sshsrv {

      # Ensure OpenSSH is enabled and running
      service { $sshsrv:
        ensure => running,
        enable => true,
      }

      # Build configuration array for augeas
      if $default_settings == undef and $custom_settings == undef {
        $_settings = ''
      } elsif $default_settings == undef {
        $_settings = $custom_settings
      } elsif $custom_settings == undef {
        $_settings = $default_settings
      } else {
        $_settings = concat( $default_settings, $custom_settings )
      }

      # Use augeas to apply modifications
      augeas { 'sshd_config':
        context => '/files/etc/ssh/sshd_config',
        changes => $_settings,
        notify  => Service[$sshsrv],
      }

    } else { alert('Unsupported OS') }

  }

  # Call build_config without special options (default configuration)
  build_config { 'default':
    default_settings => undef,
    custom_settings  => undef,
  }

}

