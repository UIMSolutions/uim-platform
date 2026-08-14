module uim.platform.architecture.domain.ports.usecases.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageBusinessBlocksUseCase {

    BusinessBlock[] listBlocks(TenantId tenantId);
    BusinessBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    CommandResult createBlock(CreateBusinessBlockRequest req);
    BusinessBlock getBlock(TenantId tenantId, BusinessBlockId id);
    CommandResult updateBlock(UpdateBusinessBlockRequest req);
    CommandResult deleteBlock(TenantId tenantId, BusinessBlockId id);

}
