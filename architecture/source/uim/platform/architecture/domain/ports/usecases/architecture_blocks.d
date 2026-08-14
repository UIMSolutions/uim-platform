module uim.platform.architecture.domain.ports.usecases.architecture_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageArchitectureBlocksUseCase {

    ArchitectureBlock[] listBlocks(TenantId tenantId);
    ArchitectureBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    CommandResult createBlock(CreateArchitectureBlockRequest req);
    ArchitectureBlock getBlock(TenantId tenantId, ArchitectureBlockId id);
    CommandResult updateBlock(UpdateArchitectureBlockRequest req);
    CommandResult deleteBlock(TenantId tenantId, ArchitectureBlockId id);

}
