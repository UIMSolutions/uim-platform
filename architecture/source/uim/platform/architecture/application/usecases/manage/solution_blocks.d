module uim.platform.architecture.application.usecases.manage.solution_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageSolutionBlocksUseCase {
    private ISolutionBlockRepository repository;

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

    this(ISolutionBlockRepository repository) {
        this.repository = repository;
    }

    SolutionBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    SolutionBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    SolutionBlock[] listBlocks(TenantId tenantId, ArchiMateDomain domain) {
        return repository.findByDomain(tenantId, domain);
    }

    UsecaseResult createBlock(CreateSolutionBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = SolutionBlock(req.tenantId);
        block.id = req.blockId.isNull ? SolutionBlockId(generateId()) : req.blockId;
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.mappedAbbId = req.mappedAbbId;
        block.vendorOrComponent = req.vendorOrComponent;
        block.deploymentEndpoint = req.deploymentEndpoint;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.application
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.activeStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);

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

        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.mappedAbbId = req.mappedAbbId;
        block.vendorOrComponent = req.vendorOrComponent;
        block.deploymentEndpoint = req.deploymentEndpoint;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.application
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.activeStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);
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
