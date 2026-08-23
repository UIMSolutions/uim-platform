module uim.platform.architecture.application.usecases.manage.data_blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageDataBlocksUseCase {
    private IDataBlockRepository repository;

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

    this(IDataBlockRepository repository) {
        this.repository = repository;
    }

    DataBlock[] listBlocks(TenantId tenantId) {
        return repository.findByTenant(tenantId);
    }

    DataBlock[] listBlocks(TenantId tenantId, LifecycleStatus status) {
        return repository.findByStatus(tenantId, status);
    }

    DataBlock[] listBlocks(TenantId tenantId, ArchiMateDomain domain) {
        return repository.findByDomain(tenantId, domain);
    }

    UsecaseResult createBlock(CreateDataBlockRequest req) {
        if (req.title.isEmpty)
            return UsecaseResult(false, "", "Title is required");

        auto block = DataBlock(req.tenantId);
        block.id = req.blockId.isNull ? DataBlockId(generateId()) : req.blockId;
        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.dataOwner = req.dataOwner;
        block.dataClassification = req.dataClassification;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.application
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.passiveStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);

        repository.save(block);
        return UsecaseResult(true, block.id.value, "Data block created");
    }

    DataBlock getBlock(TenantId tenantId, DataBlockId blockId) {
        return repository.findById(tenantId, blockId);
    }

    UsecaseResult updateBlock(UpdateDataBlockRequest req) {
        auto block = repository.findById(req.tenantId, req.blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Data block not found");

        block.title = req.title;
        block.description = req.description;
        block.owner = req.owner;
        block.status = req.status.isEmpty ? LifecycleStatus.proposed : toLifecycleStatus(req.status);
        block.versionLabel = req.versionLabel;
        block.tags = req.tags;
        block.dataOwner = req.dataOwner;
        block.dataClassification = req.dataClassification;
        block.archimateDomain = req.archimateDomain.isEmpty
            ? ArchiMateDomain.application
            : toArchiMateDomain(req.archimateDomain);
        block.archimateAspect = req.archimateAspect.isEmpty
            ? ArchiMateAspect.passiveStructure
            : toArchiMateAspect(req.archimateAspect);
        block.viewpoint = req.viewpoint;
        block.relationships = mapRelationships(req.relationships);
        block.updatedAt = currentTimestamp();

        repository.update(block);
        return UsecaseResult(true, block.id.value, "Data block updated");
    }

    UsecaseResult deleteBlock(TenantId tenantId, DataBlockId blockId) {
        auto block = repository.findById(tenantId, blockId);
        if (block.id.value.length == 0)
            return UsecaseResult(false, "", "Data block not found");

        repository.remove(block);
        return UsecaseResult(true, blockId.value, "Data block deleted");
    }
}
