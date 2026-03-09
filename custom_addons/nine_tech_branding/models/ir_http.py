from odoo import models


class IrHttp(models.AbstractModel):
    _inherit = "ir.http"

    def session_info(self):
        result = super().session_info()
        result["support_url"] = result.get("web.base.url") or "/odoo"
        return result
