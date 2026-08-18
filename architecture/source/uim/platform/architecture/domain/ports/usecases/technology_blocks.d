module uim.platform.architecture.domain.ports.usecases.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageTechnologyBlocksUseCase {

    TechnologyBlock[] listBlocks(TenantId tenantId);
    TechnologyBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    UsecaseResult createBlock(CreateTechnologyBlockRequest req);
    TechnologyBlock getBlock(TenantId tenantId, TechnologyBlockId id);
    UsecaseResult updateBlock(UpdateTechnologyBlockRequest req);
    UsecaseResult deleteBlock(TenantId tenantId, TechnologyBlockId id);

}
