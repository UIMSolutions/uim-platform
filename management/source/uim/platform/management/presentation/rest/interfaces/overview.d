module uim.platform.management.presentation.rest.interfaces.overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IOverviewApi {
    // GET /rest/v1/overview
    @headerParam("tenantId", "X-Tenant-ID")
    Json getOverview(string tenantId);
}