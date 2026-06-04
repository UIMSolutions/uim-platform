module uim.platform.management.presentation.rest.interfaces.event;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IEnvironmentEventApi {
    // GET /rest/v1/events
    // @headerParam("tenantId", "X-Tenant-ID")
    // EnvironmentEventId[] getEvents(string tenantId);

    // // GET /rest/v1/events/:id
    // @headerParam("tenantId", "X-Tenant-ID")
    // EnvironmentEventId getEvent(string tenantId, string id);
}