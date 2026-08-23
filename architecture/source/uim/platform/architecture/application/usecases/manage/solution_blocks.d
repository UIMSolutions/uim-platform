module uim.platform.architecture.application.usecases.manage.solution_blocks;

import std.conv : to;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageSolutionBlocksUseCase {
    private ISolutionBlockRepository repository;

    private bool hasTitle(SolutionBlock[] blocks, string title) {
        foreach (block; blocks) {
            if (block.title == title) {
                return true;
            }
        }
        return false;
    }

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

    SolutionBlock[] listBlocks(TenantId tenantId, ArchiMateAspect aspect) {
        return repository.findByAspect(tenantId, aspect);
    }

    SolutionBlock[] listBlocksByLeanIXObjectType(TenantId tenantId, LeanIXSolutionObjectType objectType) {
        return repository.findByLeanIXObjectType(tenantId, objectType);
    }

    UsecaseResult createLeanIXDefaultSolutionObjects(TenantId tenantId) {
        auto existingBlocks = repository.findByTenant(tenantId);
        size_t created = 0;

        foreach (objectType; defaultLeanIXSolutionObjectTypes()) {
            auto title = "LeanIX Solution " ~ objectType.toString;
            if (hasTitle(existingBlocks, title)) {
                continue;
            }

            auto block = SolutionBlock(tenantId, SolutionBlockId(generateId()));
            block.title = title;
            block.description = "Seeded SAP LeanIX solution object of type " ~ objectType.toString;
            block.owner = "leanix-sync";
            block.status = LifecycleStatus.active;
            block.versionLabel = "1.0.0";
            block.tags = ["sap", "leanix", "solution", "seeded"];
            block.mappedAbbId = "";
            block.vendorOrComponent = "";
            block.deploymentEndpoint = "";
            block.leanixObjectType = objectType;
            block.leanixFactSheetId = "";
            block.providerApplicationId = "";
            block.consumerApplicationId = "";
            block.archimateDomain = ArchiMateDomain.application;
            block.archimateAspect = ArchiMateAspect.activeStructure;
            block.viewpoint = "applicationStructure";
            repository.save(block);
            existingBlocks ~= block;
            created++;
        }

        return UsecaseResult(true, created.to!string, "LeanIX default solution objects created: " ~ created.to!string);
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
        block.leanixObjectType = req.leanixObjectType.isEmpty
            ? LeanIXSolutionObjectType.application
            : toLeanIXSolutionObjectType(req.leanixObjectType);
        block.leanixFactSheetId = req.leanixFactSheetId;
        block.providerApplicationId = req.providerApplicationId;
        block.consumerApplicationId = req.consumerApplicationId;
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
        block.leanixObjectType = req.leanixObjectType.isEmpty
            ? LeanIXSolutionObjectType.application
            : toLeanIXSolutionObjectType(req.leanixObjectType);
        block.leanixFactSheetId = req.leanixFactSheetId;
        block.providerApplicationId = req.providerApplicationId;
        block.consumerApplicationId = req.consumerApplicationId;
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
