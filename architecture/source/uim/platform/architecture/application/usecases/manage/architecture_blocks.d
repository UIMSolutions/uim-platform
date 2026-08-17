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
        if (req.title.isEmpty)
            return CommandResult(false, "", "Title is required");

        auto block = ArchitectureBlock(req.tenantId, req.blockId);
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;

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
///
unittest {
    void testManageArchitectureBlocksUseCase() {
        auto repo = new ArchitectureBlockRepository();
        auto usecase = new ManageArchitectureBlocksUseCase(repo);
        auto tenantId = TenantId("tenant1");

        auto createReq = CreateArchitectureBlockRequest(tenantId, "Test Block", "Description");
        auto createResult = usecase.createBlock(createReq);
        assert(createResult.success);

        auto blockId = ArchitectureBlockId(createResult.blockId);
        auto block = usecase.getBlock(tenantId, blockId);
        assert(block.id == blockId);

        auto updateReq = UpdateArchitectureBlockRequest(tenantId, blockId, "Updated Block", "Updated Description");
        auto updateResult = usecase.updateBlock(updateReq);
        assert(updateResult.success);

        auto deleteResult = usecase.deleteBlock(tenantId, blockId);
        assert(deleteResult.success);
    }

    testManageArchitectureBlocksUseCase();
}
