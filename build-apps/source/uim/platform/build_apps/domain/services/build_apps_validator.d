/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.services.build_apps_validator;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct BuildAppsValidator {
    static bool isValidApplication(Application app) {
        return app.name.length > 0 && app.tenantId.value.length > 0;
    }

    static bool isValidPage(Page p) {
        return p.name.length > 0 && p.tenantId.value.length > 0 && p.applicationId.value.length > 0;
    }

    static bool isValidUIComponent(UIComponent c) {
        return c.name.length > 0 && c.tenantId.value.length > 0;
    }

    static bool isValidDataEntity(DataEntity de) {
        return de.name.length > 0 && de.tenantId.value.length > 0 && de.applicationId.value.length > 0;
    }

    static bool isValidDataConnection(DataConnection dc) {
        return dc.name.length > 0 && dc.tenantId.value.length > 0 && dc.applicationId.value.length > 0;
    }

    static bool isValidLogicFlow(LogicFlow lf) {
        return lf.name.length > 0 && lf.tenantId.value.length > 0 && lf.applicationId.value.length > 0;
    }

    static bool isValidAppBuild(AppBuild ab) {
        return ab.name.length > 0 && ab.tenantId.value.length > 0 && ab.applicationId.value.length > 0;
    }

    static bool isValidProjectMember(ProjectMember pm) {
        return pm.userId.length > 0 && pm.tenantId.value.length > 0 && pm.applicationId.value.length > 0;
    }
}
