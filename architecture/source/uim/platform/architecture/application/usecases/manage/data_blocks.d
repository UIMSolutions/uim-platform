module uim.platform.architecture.application.usecases.manage.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageDataBlocksUseCase {
    private IDataBlockRepository repository;

    this(IDataBlockRepository repository) {
        this.repository = repository;
    }

    DataBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    DataBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    UsecaseResult createBlock(CreateDataBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = DataBlock(req.tenantId, DataBlockId(generateId()));

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Data block created");
    }

    DataBlock getBlock(TenantId tenantId, DataBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateDataBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Data block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Data block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, DataBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Data block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Data block deleted");
    }
}
