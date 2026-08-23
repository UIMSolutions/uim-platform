module uim.platform.architecture.presentation.rest.services.solution_blocks;

import uim.platform.architecture;
import uim.platform.architecture.presentation.rest.interfaces.solution_blocks;

mixin(ShowModule!());

@safe:

class SolutionBlocksService : ISolutionBlocksApi {
    private ManageSolutionBlocksUseCase usecase;

    this(ManageSolutionBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override SolutionBlock[] listSolutionBlocks(string tenantId) {
        return usecase.listBlocks(TenantId(tenantId));
    }

    override SolutionBlock[] listSolutionBlocksByDomain(string tenantId, string domain) {
        return usecase.listBlocks(TenantId(tenantId), toArchiMateDomain(domain));
    }

    override SolutionBlock getSolutionBlock(string tenantId, string id) {
        return usecase.getBlock(TenantId(tenantId), SolutionBlockId(id));
    }

    override UsecaseResult createSolutionBlock(string tenantId, CreateSolutionBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        return usecase.createBlock(req);
    }

    override UsecaseResult updateSolutionBlock(string tenantId, string id, UpdateSolutionBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        req.blockId = SolutionBlockId(id);
        return usecase.updateBlock(req);
    }

    override UsecaseResult deleteSolutionBlock(string tenantId, string id) {
        return usecase.deleteBlock(TenantId(tenantId), SolutionBlockId(id));
    }
}
