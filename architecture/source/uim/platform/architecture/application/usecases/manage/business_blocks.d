module uim.platform.architecture.application.usecases.manage.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageBusinessBlocksUseCase {
    private IBusinessBlockRepository repository;

    this(IBusinessBlockRepository repository) {
        this.repository = repository;
    }

    BusinessBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    BusinessBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    UsecaseResult createBlock(CreateBusinessBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = BusinessBlock(req.tenantId, BusinessBlockId(generateId()));

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Business block created");
    }

    BusinessBlock getBlock(TenantId tenantId, BusinessBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateBusinessBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Business block not found");

        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Business block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, BusinessBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Business block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Business block deleted");
    }
}
