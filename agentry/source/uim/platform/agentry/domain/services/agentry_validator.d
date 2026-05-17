/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.services.agentry_validator;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class AgentryValidator {
    static bool isValidMobileApplication(const MobileApplication app) {
        return app.name.length > 0 && app.packageName.length > 0;
    }

    static bool isValidAppDefinition(const AppDefinition def) {
        return def.name.length > 0 && def.definitionContent.length > 0
            && def.definitionFormat.length > 0;
    }

    static bool isValidAppVersion(const AppVersion ver) {
        return ver.versionNumber.length > 0
            && !ver.mobileApplicationId.isNull
            && !ver.definitionId.isNull;
    }

    static bool isValidDevice(const Device device) {
        return device.deviceName.length > 0
            && device.osVersion.length > 0
            && !device.mobileApplicationId.isNull;
    }

    static bool isValidSyncSession(const SyncSession session) {
        return !session.deviceId.isNull
            && !session.mobileApplicationId.isNull
            && !session.backendConnectionId.isNull;
    }

    static bool isValidBackendConnection(const BackendConnection conn) {
        return conn.name.length > 0 && conn.backendUrl.length > 0;
    }

    static bool isValidDeployment(const Deployment dep) {
        return !dep.mobileApplicationId.isNull && !dep.appVersionId.isNull;
    }
}
