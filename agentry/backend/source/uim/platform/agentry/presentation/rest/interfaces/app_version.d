/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.app_version;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IAppVersionApi {
    @headerParam("tenantId", "X-Tenant-Id")
    AppVersion[] listAppVersions(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    AppVersion getAppVersion(string tenantId, string versionId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createAppVersion(string tenantId, AppVersion version_);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateAppVersion(string tenantId, AppVersion version_);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteAppVersion(string tenantId, string versionId);
}
