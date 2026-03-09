from odoo import http
from odoo.http import request


class Session(http.Controller):
    @http.route('/web/session/account', type='jsonrpc', auth='user', readonly=True)
    def account(self):
        return request.env['ir.config_parameter'].sudo().get_param('web.base.url', default='/odoo')
