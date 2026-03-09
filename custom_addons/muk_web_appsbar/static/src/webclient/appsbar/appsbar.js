import { url } from '@web/core/utils/urls';
import { useService } from '@web/core/utils/hooks';
import { user } from "@web/core/user";

import { Component, onMounted, onWillUnmount } from '@odoo/owl';

export class AppsBar extends Component {
	static template = 'muk_web_appsbar.AppsBar';
    static props = {};
	setup() {
        this.appMenuService = useService('app_menu');
        this.storageKey = "mk_appsbar_collapsed";
        this.canToggleSidebar = !document.body.classList.contains("mk_sidebar_type_invisible");
        this.isSidebarCollapsed = this._readInitialCollapsedState();
    	if (user.activeCompany.has_appsbar_image) {
            this.sidebarImageUrl = url('/web/image', {
                model: 'res.company',
                field: 'appbar_image',
                id: user.activeCompany.id,
            });
    	}
    	const renderAfterMenuChange = () => {
            this.render();
        };
        this.env.bus.addEventListener(
        	'MENUS:APP-CHANGED', renderAfterMenuChange
        );
        this.onWindowResize = () => {
            this._applyRuntimeSidebarState();
        };
        onMounted(() => {
            this._applyRuntimeSidebarState();
            window.addEventListener("resize", this.onWindowResize);
        });
        onWillUnmount(() => {
            this._cleanupRuntimeSidebarState();
            window.removeEventListener("resize", this.onWindowResize);
            this.env.bus.removeEventListener(
            	'MENUS:APP-CHANGED', renderAfterMenuChange
            );
        });
    }
    _onAppClick(app) {
        return this.appMenuService.selectApp(app);
    }
    toggleSidebar() {
        if (!this.canToggleSidebar) {
            return;
        }
        this.isSidebarCollapsed = !this.isSidebarCollapsed;
        window.localStorage.setItem(this.storageKey, this.isSidebarCollapsed ? "1" : "0");
        this._applyRuntimeSidebarState();
        this.render();
    }
    _readInitialCollapsedState() {
        const persistedState = window.localStorage.getItem(this.storageKey);
        if (persistedState !== null) {
            return persistedState === "1";
        }
        return document.body.classList.contains("mk_sidebar_type_small");
    }
    _isMobileViewport() {
        return window.matchMedia("(max-width: 991.98px)").matches;
    }
    _applyRuntimeSidebarState() {
        const body = document.body;
        body.classList.remove("mk_sidebar_runtime_collapsed", "mk_sidebar_runtime_expanded");
        if (!this.canToggleSidebar || this._isMobileViewport()) {
            return;
        }
        body.classList.add(
            this.isSidebarCollapsed
                ? "mk_sidebar_runtime_collapsed"
                : "mk_sidebar_runtime_expanded"
        );
    }
    _cleanupRuntimeSidebarState() {
        document.body.classList.remove("mk_sidebar_runtime_collapsed", "mk_sidebar_runtime_expanded");
    }
}
