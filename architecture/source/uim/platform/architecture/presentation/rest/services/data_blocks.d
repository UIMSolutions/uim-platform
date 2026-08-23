module uim.platform.architecture.presentation.rest.services.data_blocks;

import uim.platform.architecture;
import uim.platform.architecture.presentation.rest.interfaces.data_blocks;

mixin(ShowModule!());

@safe:

class DataBlocksService : IDataBlocksApi {
    private ManageDataBlocksUseCase usecase;

    this(ManageDataBlocksUseCase usecase) {
        this.usecase = usecase;
    }

    override DataBlock[] listDataBlocks(string tenantId) {
        return usecase.listBlocks(TenantId(tenantId));
    }

    override DataBlock[] listDataBlocksByDomain(string tenantId, string domain) {
        return usecase.listBlocks(TenantId(tenantId), toArchiMateDomain(domain));
    }

    override DataBlock getDataBlock(string tenantId, string id) {
        return usecase.getBlock(TenantId(tenantId), DataBlockId(id));
    }

    override UsecaseResult createDataBlock(string tenantId, CreateDataBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        return usecase.createBlock(req);
    }

    override UsecaseResult updateDataBlock(string tenantId, string id, UpdateDataBlockRequest request) {
        auto req = request;
        req.tenantId = TenantId(tenantId);
        req.blockId = DataBlockId(id);
        return usecase.updateBlock(req);
    }

    override UsecaseResult deleteDataBlock(string tenantId, string id) {
        return usecase.deleteBlock(TenantId(tenantId), DataBlockId(id));
    }
}
