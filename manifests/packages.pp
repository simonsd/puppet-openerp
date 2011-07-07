class openerp::packages {
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

	file { 'openerp_sources':
		ensure => $operatingsystem ? {
            debian => present,
            default => absent,
        },
		path => '/usr/share/openerp-server-6.0.2.tar.gz',
		owner => 'openerp',
		group => 'openerp',
		mode => '0755',
		source => 'puppet:///modules/openerp/openerp-server-6.0.2.tar.gz',
		require => User['openerp'],
	}

	package { 'openerp_deps':
		ensure => installed,
		name => $operatingsystem ? {
			debian => [ 'python-pychart',
				'python-reportlab',
				'python-pydot',
				'python-tz',
				'python-egenix-mxdatetime',
				'python-yaml',
				'python-vobject',
				'python-setuptools',
				'python-psycopg2',
				'python-lxml',
				'python-mako',
			],
			default => [ 'pychart',
				'python26-pytz',
				'python-reportlab',
				'pydot',
				'mx',
				'PyYAML',
				'python26',
				'python26-devel',
				'python26-distribute',
				'python26-psycopg2',
				'python26-pyyaml',
				'python26-reportlab',
				'python26-lxml',
                'python26-dateutil',
				'openerp-server',
				'openerp-web',
			],
		},
		require => $operatingsystem ? {
			debian => File['openerp_sources'],
            default => [ Yumrepo['epel', 'psql', 'inuits'], User['openerp'] ],
		},
	}

	exec { 'openerp_unpack_sources':
		path => '/bin:/usr/bin',
		command => 'bash -c \'cd /usr/share;tar xzvf openerp-server-6.0.2.tar.gz;mv openerp-server-6.0.2 openerp\'',
		require => [ Package['openerp_deps'], File['openerp_sources'] ],
		unless => $operatingsystem ? {
            debian => 'test -d /usr/share/openerp',
            default => 'true',
        }
	}

	exec { 'openerp_install_sources':
		path => '/bin:/usr/bin',
		command => 'bash -c \'cd /usr/share/openerp && python setup.py install\'',
        unless => $operatingsystem ? {
            debian => undef,
			default => '/bin/true',
		},

		require => Exec['openerp_unpack_sources'],
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

	service { 'openerp':
		ensure => running,
		enable => true,
		name => 'openerp-server',
		require => [ File['openerp_initscript'], Class['postgresql::packages', 'postgresql::config'] ],
	}
	package { 'openerp_web_deps':
		ensure => installed,
		name => $operatingsystem ? {
			debian => [ 'python-dev', 'build-essential' ],
			default => [ 'python26-devel',
				'python26-mako',
				'python26-cherrypy',
				'python26-formencode',
				'python26-simplejson',
                'python26-babel',
                'python26-dateutil',
                ],
		},
        require => Package['openerp_deps'],
	}

	file { 'openerp_web_sources':
		ensure => $operatingsystem ? {
            debian => present,
            default => absent,
            },
		path => '/usr/share/openerp-web-6.0.2.tar.gz',
		owner => 'openerp',
		group => 'openerp',
		mode => '0755',
		source => 'puppet:///modules/openerp/openerp-web-6.0.2.tar.gz',
		before => Exec['openerp_web_unpack_sources'],
	}

	exec { 'openerp_web_unpack_sources':
		path => '/bin:/usr/bin',
		command => 'bash -c \'cd /usr/share;tar xzvf openerp-web-6.0.2.tar.gz;mv openerp-web-6.0.2 openerp-web\'',
		require => [ Package['openerp_web_deps'], File['openerp_web_sources'] ],
		unless => $operatingsystem ? {
            debian => 'test -d /usr/share/openerp-web',
            default => 'true',
        }
	}

	exec { 'openerp_web_install_sources':
		path => '/bin:/usr/bin',
		command => 'bash -c \'cd /usr/share/openerp-web && python setup.py install\'',
        onlyif => 'test -f /usr/share/openerp-web-6.0.2.tar.gz',
		require => Exec['openerp_web_unpack_sources'],
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

	service { 'openerp-web':
		ensure => running,
		enable => true,
		name => 'openerp-web',
		require => [ File['openerp-web_initscript'], Class['postgresql::packages', 'postgresql::config'] ],
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
