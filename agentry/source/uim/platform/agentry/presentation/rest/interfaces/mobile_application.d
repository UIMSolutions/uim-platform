/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.mobile_application;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IMobileApplicationApi {
    @headerParam("tenantId", "X-Tenant-Id")
    MobileApplication[] listMobileApplications(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    MobileApplication getMobileApplication(string tenantId, string applicationId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createMobileApplication(string tenantId, MobileApplication application);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateMobileApplication(string tenantId, MobileApplication application);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteMobileApplication(string tenantId, string applicationId);
}