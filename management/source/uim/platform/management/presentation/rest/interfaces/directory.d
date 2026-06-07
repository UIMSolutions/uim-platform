module uim.platform.management.presentation.rest.interfaces.directory;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
interface IDirectoryApi {
    @path("/rest/v1/directories")
    @headerParam("tenantId", "X-Tenant-ID")
    Directory[] getDirectories(string tenantId);

    @path("/rest/v1/directories/:id")
    @headerParam("tenantId", "X-Tenant-ID")
    Directory getDirectory(string tenantId, string _id);

    @path("/rest/v1/directories")
    @headerParam("tenantId", "X-Tenant-ID")
    CommandResult createDirectory(string tenantId, CreateDirectoryRequest request);
}