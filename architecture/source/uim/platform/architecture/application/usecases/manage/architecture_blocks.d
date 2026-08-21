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

    UsecaseResult createBlock(CreateArchitectureBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = ArchitectureBlock(req.tenantId);
        block.id = req.blockId.isNull ? ArchitectureBlockId(generateId()) : req.blockId;
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Architecture block created");
    }

    ArchitectureBlock getBlock(TenantId tenantId, ArchitectureBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateArchitectureBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Architecture block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Architecture block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, ArchitectureBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Architecture block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Architecture block deleted");
    }
}
///
unittest {
    void testManageArchitectureBlocksUseCase() {
        auto repo = new ArchitectureBlockRepository();
        auto usecase = new ManageArchitectureBlocksUseCase(repo);
        auto tenantId = TenantId("tenant1");

        auto createReq = CreateArchitectureBlockRequest();
        createReq.tenantId = tenantId;
        createReq.title = "Test Block";
        createReq.description = "Description";
        createReq.owner = "Owner";
        auto createResult = usecase.createBlock(createReq);
        // writeln("Created block with ID: ", createResult.id, " Message: ", createResult.message);
        assert(createResult.success, "Create operation failed");

        auto blockId = createResult.id;
        auto block = usecase.getBlock(tenantId, ArchitectureBlockId(blockId));
        // writeln("Retrieved block with ID: ", block.id.value, " Title: ", block.title, " Description: ", block.description);
        assert(block.title == "Test Block", "Retrieved block title does not match");
        assert(block.description == "Description", "Retrieved block description does not match");
        assert(block.owner == "Owner", "Retrieved block owner does not match");
        assert(block.tenantId == tenantId, "Retrieved block tenant ID does not match");
        assert(block.id.value == blockId, "Retrieved block ID does not match created block ID");

        auto updateReq = UpdateArchitectureBlockRequest();
        updateReq.tenantId = tenantId;
        updateReq.blockId = block.id;
        updateReq.title = "Updated Block";
        updateReq.description = "Updated Description";
        auto updateResult = usecase.updateBlock(updateReq);
        // writeln("Updated block with ID: ", updateResult.id, " Message: ", updateResult.message);
        assert(updateResult.success, "Update operation failed");

        auto deleteResult = usecase.deleteBlock(tenantId, ArchitectureBlockId(blockId));
        assert(deleteResult.success, "Delete operation failed");
    }

    testManageArchitectureBlocksUseCase();
}
