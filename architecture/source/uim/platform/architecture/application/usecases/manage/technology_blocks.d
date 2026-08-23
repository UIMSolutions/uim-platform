module uim.platform.architecture.application.usecases.manage.technology_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageTechnologyBlocksUseCase {
    private ITechnologyBlockRepository repository;

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

    this(ITechnologyBlockRepository repository) {
        this.repository = repository;
    }

    TechnologyBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    TechnologyBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    TechnologyBlock[] listBlocks(TenantId tenantId, ArchiMateDomain domain) {
        return repository.findByDomain(tenantId, domain);
    }

    UsecaseResult createBlock(CreateTechnologyBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "title is required");

        auto block = TechnologyBlock(req.tenantId);
        block.id = req.blockId.isNull ? TechnologyBlockId(generateId()) : req.blockId;
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.technology
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.activeStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);

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

        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.technology
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.activeStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);
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
