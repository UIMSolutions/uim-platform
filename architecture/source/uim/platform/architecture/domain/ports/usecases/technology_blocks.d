module uim.platform.architecture.domain.ports.usecases.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageTechnologyBlocksUseCase {

    TechnologyBlock[] listBlocks(TenantId tenantId);
    TechnologyBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    CommandResult createBlock(CreateTechnologyBlockRequest req);
    TechnologyBlock getBlock(TenantId tenantId, TechnologyBlockId id);
    CommandResult updateBlock(UpdateTechnologyBlockRequest req);
    CommandResult deleteBlock(TenantId tenantId, TechnologyBlockId id);

}
