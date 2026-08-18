module uim.platform.architecture.presentation.rest.interfaces.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IBusinessBlocksApi {
    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.GET)
    BusinessBlock[] listBusinessBlocks(string tenantId);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.GET)
    BusinessBlock getBusinessBlock(string tenantId, string _id);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/") @method(HTTPMethod.POST)
    UsecaseResult createBusinessBlock(string tenantId, CreateBusinessBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.PUT)
    UsecaseResult updateBusinessBlock(string tenantId, string _id, UpdateBusinessBlockRequest request);

    @headerParam("tenantId", "X-Tenant-ID")
    @path("/:id") @method(HTTPMethod.DELETE)
    UsecaseResult deleteBusinessBlock(string tenantId, string _id);
}
