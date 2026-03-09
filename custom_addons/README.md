# 9Tech Custom Addons

This directory is the product layer for ERP customizations.

Rules:
- Do not edit core files under `addons/` or `odoo/` for business features.
- Keep business logic in versioned modules under `custom_addons/`.
- Keep third-party community modules here when they are not part of official Odoo source.

Starter modules:
- `company_base`
- `company_sales`
- `company_purchase`
- `company_inventory`

Third-party UI modules:
- `muk_web_appsbar`
- `muk_web_chatter`
- `muk_web_colors`
- `muk_web_dialog`
- `muk_web_group`
- `muk_web_refresh`
- `muk_web_theme`
