module uim.platform.architecture.domain.ports.usecases.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageDataBlocksUseCase {

    DataBlock[] listBlocks(TenantId tenantId);
    DataBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    CommandResult createBlock(CreateDataBlockRequest req);
    DataBlock getBlock(TenantId tenantId, DataBlockId id);
    CommandResult updateBlock(UpdateDataBlockRequest req);
    CommandResult deleteBlock(TenantId tenantId, DataBlockId id);

}
