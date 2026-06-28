/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.presentation.rest.interfaces.deployment;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

interface IDeploymentApi {
    @headerParam("tenantId", "X-Tenant-Id")
    Deployment[] listDeployments(string tenantId);

    @headerParam("tenantId", "X-Tenant-Id")
    Deployment getDeployment(string tenantId, string deploymentId);

    @headerParam("tenantId", "X-Tenant-Id")
    void createDeployment(string tenantId, Deployment deployment);

    @headerParam("tenantId", "X-Tenant-Id")
    void updateDeployment(string tenantId, Deployment deployment);

    @headerParam("tenantId", "X-Tenant-Id")
    void deleteDeployment(string tenantId, string deploymentId);
}
