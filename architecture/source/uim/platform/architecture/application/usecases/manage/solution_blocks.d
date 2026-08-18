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

    UsecaseResult createBlock(CreateSolutionBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = SolutionBlock(req.tenantId, req.blockId);
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Solution block created");
    }

    SolutionBlock getBlock(TenantId tenantId, SolutionBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateSolutionBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Solution block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Solution block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, SolutionBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Solution block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Solution block deleted");
    }
}
