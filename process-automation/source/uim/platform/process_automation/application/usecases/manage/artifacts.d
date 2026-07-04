/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.application.usecases.manage.artifacts;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class ManageArtifactsUseCase { // TODO: UIMUseCase {
    private ArtifactRepository repo;

    this(ArtifactRepository repo) {
        this.repo = repo;
    }

    CommandResult createArtifact(CreateArtifactRequest r) {
        if (r.artifactId.isEmpty)
            return CommandResult(false, "", "Artifact ID is required");
        if (r.name.length == 0)
            return CommandResult(false, "", "Artifact name is required");

        auto existing = repo.findById(r.tenantId, r.artifactId);
        if (!existing.isNull)
            return CommandResult(false, "", "Artifact already exists");

        auto a = Artifact(r.tenantId, r.artifactId, r.createdBy);
        a.name = r.name;
        a.description = r.description;
        a.status = ArtifactStatus.available;
        a.version_ = r.version_;
        a.author = r.author;
        a.category = r.category;
        a.tags = r.tags;
        a.contentUrl = r.contentUrl;
        a.publishedAt = a.createdAt;

        repo.save(a);
        return CommandResult(true, a.id.value, "");
    }

    Artifact getArtifact(TenantId tenantId, ArtifactId id) {
        return repo.findById(tenantId, id);
    }

    Artifact[] listArtifacts(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Artifact[] listArtifacts(TenantId tenantId, ArtifactType type) {
        return repo.findByType(tenantId, type);
    }

    CommandResult updateArtifact(UpdateArtifactRequest r) {
        auto artifact = repo.findById(r.tenantId, r.artifactId);
        if (artifact.isNull)
            return CommandResult(false, "", "Artifact not found");

        artifact.name = r.name;
        artifact.description = r.description;
        artifact.version_ = r.version_;
        artifact.contentUrl = r.contentUrl;

        
        artifact.updatedAt = currentTimestamp;

        repo.update(artifact);
        return CommandResult(true, artifact.id.value, "");
    }

    CommandResult deleteArtifact(TenantId tenantId, ArtifactId id) {
        auto artifact = repo.findById(tenantId, id);
        if (artifact.isNull)
            return CommandResult(false, "", "Artifact not found");

        repo.remove(artifact);
        return CommandResult(true, artifact.id.value, "");
    }
}
