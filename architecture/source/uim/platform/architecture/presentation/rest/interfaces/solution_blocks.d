module uim.platform.architecture.presentation.rest.interfaces.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface ISolutionBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    SolutionBlock[] listSolutionBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/domain/:domain") @method(HTTPMethod.GET)
    SolutionBlock[] listSolutionBlocksByDomain(string tenantId, string domain);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/aspect/:aspect") @method(HTTPMethod.GET)
    SolutionBlock[] listSolutionBlocksByAspect(string tenantId, string aspect);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    SolutionBlock getSolutionBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    UsecaseResult createSolutionBlock(string tenantId, CreateSolutionBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    UsecaseResult updateSolutionBlock(string tenantId, string _id, UpdateSolutionBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    UsecaseResult deleteSolutionBlock(string tenantId, string _id);
}
