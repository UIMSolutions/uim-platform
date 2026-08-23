module uim.platform.architecture.presentation.rest.services.architecture_blocks;

import uim.platform.architecture;
import uim.platform.architecture.presentation.rest.interfaces.architecture_blocks;

mixin(ShowModule!());

@safe:

class ArchitectureBlocksService : IArchitectureBlocksApi {
    private ManageArchitectureBlocksUseCase usecase;

    this(ManageArchitectureBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override ArchitectureBlock[] listArchitectureBlocks(string tenantId) {
        return usecase.listBlocks(TenantId(tenantId));
    }

    override ArchitectureBlock[] listArchitectureBlocksByDomain(string tenantId, string domain) {
        return usecase.listBlocks(TenantId(tenantId), toArchiMateDomain(domain));
    }

    override ArchitectureBlock[] listArchitectureBlocksByAspect(string tenantId, string aspect) {
        return usecase.listBlocks(TenantId(tenantId), toArchiMateAspect(aspect));
    }

    override ArchitectureBlock getArchitectureBlock(string tenantId, string id) {
        return usecase.getBlock(TenantId(tenantId), ArchitectureBlockId(id));
    }

    override UsecaseResult createArchitectureBlock(string tenantId, CreateArchitectureBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        return usecase.createBlock(req);
    }

    override UsecaseResult updateArchitectureBlock(string tenantId, string id, UpdateArchitectureBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        req.blockId = ArchitectureBlockId(id);
        return usecase.updateBlock(req);
    }

    override UsecaseResult deleteArchitectureBlock(string tenantId, string id) {
        return usecase.deleteBlock(TenantId(tenantId), ArchitectureBlockId(id));
    }
}
