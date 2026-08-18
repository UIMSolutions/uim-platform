module uim.platform.architecture.presentation.rest.services.business_blocks;

import uim.platform.architecture;
import uim.platform.architecture.presentation.rest.interfaces.business_blocks;

mixin(ShowModule!());

@safe:

class BusinessBlocksService : IBusinessBlocksApi {
    private ManageBusinessBlocksUseCase usecase;

    this(ManageBusinessBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override BusinessBlock[] listBusinessBlocks(string tenantId) {
        return usecase.listBlocks(TenantId(tenantId));
    }

    override BusinessBlock getBusinessBlock(string tenantId, string id) {
        return usecase.getBlock(TenantId(tenantId), BusinessBlockId(id));
    }

    override UsecaseResult createBusinessBlock(string tenantId, CreateBusinessBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        return usecase.createBlock(req);
    }

    override UsecaseResult updateBusinessBlock(string tenantId, string id, UpdateBusinessBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        req.blockId = BusinessBlockId(id);
        return usecase.updateBlock(req);
    }

    override UsecaseResult deleteBusinessBlock(string tenantId, string id) {
        return usecase.deleteBlock(TenantId(tenantId), BusinessBlockId(id));
    }
}
