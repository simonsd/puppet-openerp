import 'packages.pp'
import 'config.pp'
import 'services.pp'

class openerp {
	include openerp::packages
	include openerp::config
	include openerp::services
}
