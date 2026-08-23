module uim.platform.architecture.application.usecases.manage.business_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageBusinessBlocksUseCase {
    private IBusinessBlockRepository repository;

    private ArchiMateRelationship[] mapRelationships(ArchiMateRelationshipRequest[] relationshipRequests) {
        ArchiMateRelationship[] relationships;

        foreach (request; relationshipRequests) {
            ArchiMateRelationship relationship;
            relationship.relationshipType = toArchiMateRelationshipType(request.relationshipType);
            relationship.targetBlockId = request.targetBlockId;
            relationship.description = request.description;
            relationships ~= relationship;
        }

        return relationships;
    }

    this(IBusinessBlockRepository repository) {
        this.repository = repository;
    }

    BusinessBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    BusinessBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    BusinessBlock[] listBlocks(TenantId tenantId, ArchiMateDomain domain) {
        return repository.findByDomain(tenantId, domain);
    }

    BusinessBlock[] listBlocks(TenantId tenantId, ArchiMateAspect aspect) {
        return repository.findByAspect(tenantId, aspect);
    }

    UsecaseResult createBlock(CreateBusinessBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = BusinessBlock(req.tenantId);
        block.id = req.blockId.isNull ? BusinessBlockId(generateId()) : req.blockId;
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.lifecycleState = req.lifecycleState;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.business
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.behavior
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);

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

        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.lifecycleState = req.lifecycleState;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.business
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.behavior
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);
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
