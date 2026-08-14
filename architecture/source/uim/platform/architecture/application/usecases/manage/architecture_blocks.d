module uim.platform.architecture.application.usecases.manage.architecture_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageArchitectureBlocksUseCase {
    private IArchitectureBlockRepository repository;

    this(IArchitectureBlockRepository repository) {
        this.repository = repository;
    }

    ArchitectureBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    ArchitectureBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    CommandResult createBlock(CreateArchitectureBlockRequest req) {
        if (req.name.isEmpty)
            return CommandResult(false, "", "Name is required");

        auto block = ArchitectureBlock(req.tenantId, ArchitectureBlockId(generateId()));

        repository.save(block);
        return CommandResult(true, block.id.value, "Architecture block created");
    }

    ArchitectureBlock getBlock(TenantId tenantId, ArchitectureBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    CommandResult updateBlock(UpdateArchitectureBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Architecture block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return CommandResult(true, block.id.value, "Architecture block updated");
    }

    CommandResult deleteBlock(TenantId tenantId, ArchitectureBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Architecture block not found");

        repository.remove(block);
        return CommandResult(true, blockId.value, "Architecture block deleted");
    }
}
