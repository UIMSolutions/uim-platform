module uim.platform.architecture.presentation.rest.interfaces.architecture_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IArchitectureBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    ArchitectureBlock[] listArchitectureBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    ArchitectureBlock getArchitectureBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    CommandResult createArchitectureBlock(string tenantId, CreateArchitectureBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    CommandResult updateArchitectureBlock(string tenantId, string _id, UpdateArchitectureBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    CommandResult deleteArchitectureBlock(string tenantId, string _id);
}
