from odoo import fields, models


class StockPicking(models.Model):
    _inherit = "stock.picking"

    x_dispatch_priority = fields.Selection(
        selection=[
            ("normal", "Normal"),
            ("high", "High"),
            ("urgent", "Urgent"),
        ],
        string="Dispatch Priority",
        default="normal",
    )
    x_processing_note = fields.Text(string="Processing Note")
