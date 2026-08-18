module uim.platform.architecture.presentation.rest.interfaces.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IDataBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    DataBlock[] listDataBlocks(string tenantId);

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
