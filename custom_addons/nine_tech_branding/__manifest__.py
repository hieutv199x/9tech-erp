{
    "name": "9tech ERP Branding",
    "summary": "White-label Odoo branding for 9tech",
    "description": """
Replace default Odoo-facing brand strings in backend/login/email UI with 9tech branding.
    """,
    "version": "19.0.1.0.0",
    "category": "Tools",
    "license": "LGPL-3",
    "author": "9tech",
    "website": "https://9tech.vn",
    "depends": [
        "web",
        "mail",
        "muk_web_theme",
    ],
    "data": [
        "views/web_branding_templates.xml",
        "data/mail_branding_data.xml",
    ],
    "assets": {
        "web.assets_backend": [
            "nine_tech_branding/static/src/js/title_service.js",
            "nine_tech_branding/static/src/js/user_menu_items.js",
            "nine_tech_branding/static/src/xml/res_config_edition.xml",
            "nine_tech_branding/static/src/xml/notification_alert.xml",
        ],
    },
    "installable": True,
    "application": False,
}
