module uim.platform.architecture.presentation.rest.interfaces.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IDataBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    DataBlock[] listDataBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/domain/:domain") @method(HTTPMethod.GET)
    DataBlock[] listDataBlocksByDomain(string tenantId, string domain);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/aspect/:aspect") @method(HTTPMethod.GET)
    DataBlock[] listDataBlocksByAspect(string tenantId, string aspect);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/leanix/object-type/:objectType") @method(HTTPMethod.GET)
    DataBlock[] listDataBlocksByLeanIXObjectType(string tenantId, string objectType);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/leanix/defaults") @method(HTTPMethod.POST)
    UsecaseResult createLeanIXDefaultDataObjects(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    DataBlock getDataBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    UsecaseResult createDataBlock(string tenantId, CreateDataBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    UsecaseResult updateDataBlock(string tenantId, string _id, UpdateDataBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    UsecaseResult deleteDataBlock(string tenantId, string _id);
}
