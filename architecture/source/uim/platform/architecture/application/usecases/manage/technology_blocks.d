module uim.platform.architecture.application.usecases.manage.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageTechnologyBlocksUseCase {
    private ITechnologyBlockRepository repository;

    this(ITechnologyBlockRepository repository) {
        this.repository = repository;
    }

    TechnologyBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    TechnologyBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    UsecaseResult createBlock(CreateTechnologyBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "title is required");

        auto block = TechnologyBlock(req.tenantId, TechnologyBlockId(generateId()));

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Technology block created");
    }

    TechnologyBlock getBlock(TenantId tenantId, TechnologyBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateTechnologyBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Technology block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Technology block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, TechnologyBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Technology block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Technology block deleted");
    }
}
