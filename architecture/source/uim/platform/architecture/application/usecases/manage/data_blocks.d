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

    CommandResult createBlock(CreateDataBlockRequest req) {
        if (req.name.isEmpty)
            return CommandResult(false, "", "name is required");

        auto block = DataBlock(req.tenantId, DataBlockId(generateId()));

        repository.save(block);
        return CommandResult(true, block.id.value, "Data block created");
    }

    DataBlock getBlock(TenantId tenantId, DataBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    CommandResult updateBlock(UpdateDataBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Data block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return CommandResult(true, block.id.value, "Data block updated");
    }

    CommandResult deleteBlock(TenantId tenantId, DataBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Data block not found");

        repository.remove(block);
        return CommandResult(true, blockId.value, "Data block deleted");
    }
}
