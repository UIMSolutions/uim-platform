module uim.platform.management.presentation.rest.interfaces.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IDirectoryApi {
    // GET /rest/v1/directories
    @headerParam("tenantId", "X-Tenant-ID")
    Directory[] getDirectories(string tenantId);

    // GET /rest/v1/directories/:id
    @headerParam("tenantId", "X-Tenant-ID")
    Directory getDirectory(string tenantId, string id);
}