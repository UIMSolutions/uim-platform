/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.postgres.domain.services;

mixin template PostgresValidator() {
    static bool isValidServiceInstance(ServiceInstance e) {
        return e.name.length > 0 && e.planId.value.length > 0;
    }
    static bool isValidServiceBinding(ServiceBinding e) {
        return e.instanceId.value.length > 0 && e.appId.length > 0;
    }
    static bool isValidDatabaseUser(DatabaseUser e) {
        return e.instanceId.value.length > 0 && e.username.length > 0;
    }
    static bool isValidDatabaseExtension(DatabaseExtension e) {
        return e.instanceId.value.length > 0 && e.extensionName.length > 0;
    }
}
