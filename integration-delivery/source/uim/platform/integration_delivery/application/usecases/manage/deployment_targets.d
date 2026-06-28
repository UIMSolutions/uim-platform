/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration_delivery.application.usecases.manage.deployment_targets;

import uim.platform.integration_delivery;

// mixin(ShowModule!());

@safe:

class ManageDeploymentTargetsUseCase {
    private DeploymentTargetRepository repo;

    this(DeploymentTargetRepository repo) {
        this.repo = repo;
    }

    DeploymentTarget getDeploymentTarget(TenantId tenantId, DeploymentTargetId id) {
        return repo.findById(tenantId, id);
    }

    DeploymentTarget[] listDeploymentTargets(TenantId tenantId) {
        return repo.find(tenantId);
    }

    DeploymentTarget[] listActive(TenantId tenantId) {
        return repo.findByStatus(tenantId, DeploymentTargetStatus.active);
    }

    CommandResult createDeploymentTarget(DeploymentTargetDTO dto) {
        if (repo.nameExists(dto.tenantId, dto.name))
            return CommandResult(false, "", "Deployment target name already exists");

        DeploymentTarget d;
        d.initEntity(dto.tenantId, dto.createdBy);
        d.id = dto.deploymentTargetId;
        d.name = dto.name;
        d.description = dto.description;
        d.url = dto.url;
        d.credentialId = dto.credentialId;
        d.organization = dto.organization;
        d.spaceOrNamespace = dto.spaceOrNamespace;
        d.region = dto.region;
        d.status = DeploymentTargetStatus.active;

        if (!CicdValidator.isValidDeploymentTarget(d))
            return CommandResult(false, "", "Invalid deployment target: name and url required");

        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    CommandResult updateDeploymentTarget(DeploymentTargetDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.deploymentTargetId);
        if (existing.isNull)
            return CommandResult(false, "", "Deployment target not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.url.length > 0) existing.url = dto.url;
        if (dto.organization.length > 0) existing.organization = dto.organization;
        if (dto.spaceOrNamespace.length > 0) existing.spaceOrNamespace = dto.spaceOrNamespace;
        if (dto.region.length > 0) existing.region = dto.region;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDeploymentTarget(TenantId tenantId, DeploymentTargetId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Deployment target not found");
        repo.remove(tenantId, id);
        return CommandResult(true, id.value, "");
    }
}
