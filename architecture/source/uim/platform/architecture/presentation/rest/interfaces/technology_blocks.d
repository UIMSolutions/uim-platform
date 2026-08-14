module uim.platform.architecture.presentation.rest.interfaces.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ITechnologyBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    TechnologyBlock[] listTechnologyBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    TechnologyBlock getTechnologyBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    CommandResult createTechnologyBlock(string tenantId, CreateTechnologyBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    CommandResult updateTechnologyBlock(string tenantId, string _id, UpdateTechnologyBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    CommandResult deleteTechnologyBlock(string tenantId, string _id);
}
