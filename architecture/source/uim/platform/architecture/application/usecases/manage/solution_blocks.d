module uim.platform.architecture.application.usecases.manage.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageSolutionBlocksUseCase {
    private ISolutionBlockRepository repository;

    this(ISolutionBlockRepository repository) {
        this.repository = repository;
    }

    SolutionBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    SolutionBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    CommandResult createBlock(CreateSolutionBlockRequest req) {
        if (req.title.isEmpty)
            return CommandResult(false, "", "Title is required");

        auto block = SolutionBlock(req.tenantId, req.blockId);
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;

        repository.save(block);
        return CommandResult(true, block.id.value, "Solution block created");
    }

    SolutionBlock getBlock(TenantId tenantId, SolutionBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    CommandResult updateBlock(UpdateSolutionBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Solution block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return CommandResult(true, block.id.value, "Solution block updated");
    }

    CommandResult deleteBlock(TenantId tenantId, SolutionBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return CommandResult(false, "", "Solution block not found");

        repository.remove(block);
        return CommandResult(true, blockId.value, "Solution block deleted");
    }
}
