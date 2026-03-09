# 9Tech ERP Workspace (Odoo Source + Custom Addons)

This repository follows a source-install workflow:

- Odoo source code is the platform runtime.
- Business features live in `custom_addons/`.
- Core code under `addons/` and `odoo/` should stay upstream-compatible.

## Workspace Layout

```text
9tech-erp/
├── addons/                  # upstream/community addons from Odoo source
├── odoo/                    # Odoo framework source
├── enterprise/              # optional enterprise source checkout
├── custom_addons/           # 9Tech and third-party business modules
├── config/
│   └── odoo.conf            # local source-run configuration
├── docker/
│   └── odoo.conf            # container runtime configuration
├── scripts/                 # helper scripts
├── deploy/                  # production deploy assets
└── README.md
```

## Custom Modules

Starter domain modules:

- `company_base`
- `company_sales`
- `company_purchase`
- `company_inventory`

UI extension modules moved out of core path:

- `muk_web_appsbar`
- `muk_web_chatter`
- `muk_web_colors`
- `muk_web_dialog`
- `muk_web_group`
- `muk_web_refresh`
- `muk_web_theme`

## Local Run (Source Install)

1. Create and activate a Python environment.
2. Install dependencies from `requirements.txt`.
3. Configure database credentials in `config/odoo.conf`.
4. Start Odoo from repository root:

```bash
scripts/run-dev.sh odoo
```

Or run directly:

```bash
python3 odoo-bin -c config/odoo.conf -d odoo
```

## Addons Path Policy

`config/odoo.conf` and `docker/odoo.conf` load modules in this order:

1. `custom_addons`
2. `addons`

If an enterprise checkout is added later, place it first:

```ini
addons_path = enterprise,custom_addons,addons
```

## Development Rules

- Build business behavior in `custom_addons/`.
- Prefer model and view inheritance over copying core modules.
- Keep modules small and domain-scoped.
- Add security and tests per module.
