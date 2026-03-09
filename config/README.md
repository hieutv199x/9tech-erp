# Odoo Config

- `odoo.conf` is used for local source-based development.
- Keep local secrets in `odoo.local.conf` and pass it via `ODOO_CONFIG` when needed.
- Ensure `addons_path` includes `custom_addons` before `addons`.
