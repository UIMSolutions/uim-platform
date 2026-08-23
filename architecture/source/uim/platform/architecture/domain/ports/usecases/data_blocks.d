module uim.platform.architecture.domain.ports.usecases.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageDataBlocksUseCase {

    DataBlock[] listBlocks(TenantId tenantId);
    DataBlock[] listBlocks(TenantId tenantId, LifecycleStatus status);
    DataBlock[] listBlocks(TenantId tenantId, ArchiMateDomain domain);
    DataBlock[] listBlocks(TenantId tenantId, ArchiMateAspect aspect);
    DataBlock[] listBlocksByLeanIXObjectType(TenantId tenantId, LeanIXDataObjectType objectType);
    UsecaseResult createLeanIXDefaultDataObjects(TenantId tenantId);
    UsecaseResult createBlock(CreateDataBlockRequest req);
    DataBlock getBlock(TenantId tenantId, DataBlockId id);
    UsecaseResult updateBlock(UpdateDataBlockRequest req);
    UsecaseResult deleteBlock(TenantId tenantId, DataBlockId id);

}
