module uim.platform.architecture.domain.ports.usecases.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageBusinessBlocksUseCase {

    BusinessBlock[] listBlocks(TenantId tenantId);
    BusinessBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    UsecaseResult createBlock(CreateBusinessBlockRequest req);
    BusinessBlock getBlock(TenantId tenantId, BusinessBlockId id);
    UsecaseResult updateBlock(UpdateBusinessBlockRequest req);
    UsecaseResult deleteBlock(TenantId tenantId, BusinessBlockId id);

}
