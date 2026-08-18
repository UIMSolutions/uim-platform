module uim.platform.architecture.presentation.rest.services.technology_blocks;

import uim.platform.architecture;
import uim.platform.architecture.presentation.rest.interfaces.technology_blocks;

mixin(ShowModule!());

@safe:

class TechnologyBlocksService : ITechnologyBlocksApi {
    private ManageTechnologyBlocksUseCase usecase;

    this(ManageTechnologyBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override TechnologyBlock[] listTechnologyBlocks(string tenantId) {
        return usecase.listBlocks(TenantId(tenantId));
    }

    override TechnologyBlock getTechnologyBlock(string tenantId, string id) {
        return usecase.getBlock(TenantId(tenantId), TechnologyBlockId(id));
    }

    override UsecaseResult createTechnologyBlock(string tenantId, CreateTechnologyBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        return usecase.createBlock(req);
    }

    override UsecaseResult updateTechnologyBlock(string tenantId, string id, UpdateTechnologyBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        req.blockId = TechnologyBlockId(id);
        return usecase.updateBlock(req);
    }

    override UsecaseResult deleteTechnologyBlock(string tenantId, string id) {
        return usecase.deleteBlock(TenantId(tenantId), TechnologyBlockId(id));
    }
}
