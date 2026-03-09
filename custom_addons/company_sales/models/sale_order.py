from odoo import fields, models


class SaleOrder(models.Model):
    _inherit = "sale.order"

    x_sales_channel = fields.Selection(
        selection=[
            ("offline", "Offline"),
            ("ecommerce", "E-Commerce"),
            ("marketplace", "Marketplace"),
        ],
        string="Sales Channel",
    )
    x_approval_state = fields.Selection(
        selection=[
            ("draft", "Draft"),
            ("pending", "Pending Approval"),
            ("approved", "Approved"),
            ("rejected", "Rejected"),
        ],
        string="Internal Approval",
        default="draft",
        copy=False,
    )
