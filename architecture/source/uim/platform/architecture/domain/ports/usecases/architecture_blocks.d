module uim.platform.architecture.domain.ports.usecases.architecture_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageArchitectureBlocksUseCase {

    ArchitectureBlock[] listBlocks(TenantId tenantId);
    ArchitectureBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    UsecaseResult createBlock(CreateArchitectureBlockRequest req);
    ArchitectureBlock getBlock(TenantId tenantId, ArchitectureBlockId id);
    UsecaseResult updateBlock(UpdateArchitectureBlockRequest req);
    UsecaseResult deleteBlock(TenantId tenantId, ArchitectureBlockId id);

}
