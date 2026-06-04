module uim.platform.management.presentation.rest.interfaces.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IEnvironmentApi {
    // GET /rest/v1/environments
    @headerParam("tenantId", "X-Tenant-ID")
    Environment[] getEnvironments(string tenantId);

    // GET /rest/v1/environments/:id
    @headerParam("tenantId", "X-Tenant-ID")
    Environment getEnvironment(string tenantId, string id);
}