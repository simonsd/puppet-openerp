class openerp::config {
	group { 'openerp':
		ensure => present,
		name => openerp,
	}

	user { 'openerp':
		ensure => present,
		name => openerp,
		gid => openerp,
		shell => '/bin/bash',
		managehome => true,
		require => Group['openerp'],
	}

	file { 'openerp_logfile':
		ensure => present,
		path => '/var/log/openerp-server.log',
		owner => openerp,
		group => openerp,
		mode => 644,
		require => User['openerp'],
	}

	$openerpserver_path=$operatingsystem ? {
		debian => '/usr/local/bin/openerp-server',
		default => '/usr/bin/openerp-server',
	}

	file { 'openerp_initscript':
		ensure => present,
		path => '/etc/init.d/openerp-server',
		owner => 'root',
		group => 'root',
		mode => '0755',
		require => Exec['openerp_install_sources'],
		content => $operatingsystem ? {
            debian => template('openerp/openerp_init.erb'),
            default => undef,
        },
		notify => Service['openerp'],
	}

	$openerpweb_path=$operatingsystem ? {
		debian => '/usr/local/bin/openerp-web',
		default => '/usr/bin/openerp-web',
	}

	file { 'openerp-web_initscript':
		ensure => present,
		path => '/etc/init.d/openerp-web',
		owner => 'root',
		group => 'root',
		mode => '0755',
		require => Exec['openerp_install_sources'],
		content => template('openerp/openerp-web_init.erb'),
		notify => Service['openerp-web'],
	}

	file { 'openerp-web_logdir':
		ensure => directory,
		path => '/var/log/openerp-web',
		owner => 'openerp',
		group => 'openerp',
		mode => '0644',
		require => User['openerp'],
	}

	file { 'openerp-web_accesslog':
		ensure => present,
		path => '/var/log/openerp-web/access.log',
		owner => 'openerp',
		group => 'openerp',
		mode => '0644',
		require => User['openerp'],
	}

	file { 'openerp-web_errorlog':
		ensure => present,
		path => '/var/log/openerp-web/error.log',
		owner => 'openerp',
		group => 'openerp',
		mode => '0644',
		require => User['openerp'],
	}
}
