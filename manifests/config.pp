class openerp::config {
	file { "openerp.conf":
		ensure => present,
		path => "/etc/openerp-server.cfg",
		owner => openerp,
		group => openerp,
        mode => 755,
		content => template("openerp/openerp_serverrc.erb"),
	}

	file { "openerp-web.conf":
		ensure => present,
		path => "/etc/openerp-web.cfg",
		owner => openerp,
		group => openerp,
		mode => 755,
		content => template("openerp/openerp_webrc.erb"),
		require => Exec["openerp_web_install_sources"],
	}
}
