module uim.platform.architecture.domain.ports.usecases.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageSolutionBlocksUseCase {

    SolutionBlock[] listBlocks(TenantId tenantId);
    SolutionBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    CommandResult createBlock(CreateSolutionBlockRequest req);
    SolutionBlock getBlock(TenantId tenantId, SolutionBlockId id);
    CommandResult updateBlock(UpdateSolutionBlockRequest req);
    CommandResult deleteBlock(TenantId tenantId, SolutionBlockId id);

}
