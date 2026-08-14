module uim.platform.architecture.presentation.rest.interfaces.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ISolutionBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    SolutionBlock[] listSolutionBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    SolutionBlock getSolutionBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    CommandResult createSolutionBlock(string tenantId, CreateSolutionBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    CommandResult updateSolutionBlock(string tenantId, string _id, UpdateSolutionBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    CommandResult deleteSolutionBlock(string tenantId, string _id);
}
