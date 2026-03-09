import { _t } from "@web/core/l10n/translation";
import { browser } from "@web/core/browser/browser";
import { registry } from "@web/core/registry";

export function nineTechAccountItem() {
    return {
        type: "item",
        id: "account",
        description: _t("My 9tech Account"),
        callback: () => {
            browser.open("https://9tech.vn", "_blank");
        },
        sequence: 60,
    };
}

registry.category("user_menuitems").add("odoo_account", nineTechAccountItem, { force: true });
