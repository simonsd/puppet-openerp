class openerp::services {
	service {
		'openerp':
			ensure => running,
			enable => true,
			name => 'openerp-server',
			require => [ File['openerp_initscript'], Class['postgresql::packages', 'postgresql::config'] ];

		'openerp-web':
			ensure => running,
			enable => true,
			name => 'openerp-web',
			require => [ File['openerp-web_initscript'], Class['postgresql::packages', 'postgresql::config'] ];
	}
}
