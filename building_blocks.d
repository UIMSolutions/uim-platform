module building_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageBuildingBlocksUseCase {
    private IBuildingBlockRepository repository;

    this(IBuildingBlockRepository repository) {
        this.repository = repository;
    }

    BuildingBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    BuildingBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    UsecaseResult createBlock(CreateBuildingBlockRequest req) {
        if (req.name.isEmpty)
            return UsecaseResult(false, "", "name is required");

        if (repository.existsByNameAndType(req.tenantId, req.blockType, req.name))
            return UsecaseResult(false, "", "Building block already exists for tenant and type");

        auto block = BuildingBlock(req.tenantId, BuildingBlockId(generateId()));

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Building block created");
    }

    BuildingBlock getBlock(TenantId tenantId, BuildingBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateBuildingBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Building block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Building block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, BuildingBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Building block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Building block deleted");
    }
}
