class openerp::packages {
	package {
		'openerp':
			ensure => installed,
			name => "openerp-server.$hardwaremodel";

		'openerp_deps':
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
			};
	}

	package {
		'openerp-web':
			ensure => installed,
			name => "openerp-web.$hardwaremodel";

		'openerp_web_deps':
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
    	    require => Package['openerp_deps'];
	}
}
