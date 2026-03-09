from odoo import fields, models


class PurchaseOrder(models.Model):
    _inherit = "purchase.order"

    x_supplier_channel = fields.Char(string="Supplier Channel")
    x_internal_flow_state = fields.Selection(
        selection=[
            ("draft", "Draft"),
            ("review", "Under Review"),
            ("ready", "Ready to Order"),
        ],
        string="Internal Flow",
        default="draft",
        copy=False,
    )
