/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.application.usecases.manage.deployments;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

class ManageDeploymentsUseCase {
    protected IDeploymentRepository repo;

    this(IDeploymentRepository repo) {
        this.repo = repo;
    }

    Deployment getDeployment(TenantId tenantId, DeploymentId id) {
        return repo.findById(tenantId, id);
    }

    Deployment[] listDeployments(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    Deployment[] listByMobileApplication(TenantId tenantId, MobileApplicationId appId) {
        return repo.findByMobileApplication(tenantId, appId);
    }

    Deployment[] listByStatus(TenantId tenantId, DeploymentStatus status) {
        return repo.findByStatus(tenantId, status);
    }

    CommandResult createDeployment(DeploymentDTO dto) {
        auto dep = Deployment(dto.tenantId, dto.deploymentId, dto.createdBy);
        dep.mobileApplicationId = dto.applicationId;
        dep.appVersionId = dto.versionId;
        dep.targetDeviceId = dto.targetDeviceId;
        dep.targetGroupName = dto.targetGroupName;
        dep.scheduledAt = dto.scheduledAt;
        dep.deployedBy = dto.deployedBy;
        dep.notes = dto.notes;

        if (!AgentryValidator.isValidDeployment(dep))
            return CommandResult(false, "", "Invalid deployment data");

        repo.save(dep);
        return CommandResult(true, dep.id.value, "");
    }

    CommandResult updateDeployment(DeploymentDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.deploymentId);
        if (existing.isNull)
            return CommandResult(false, "", "Deployment not found");

        if (dto.notes.length > 0) existing.notes = dto.notes;
        if (dto.scheduledAt > 0) existing.scheduledAt = dto.scheduledAt;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDeployment(TenantId tenantId, DeploymentId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Deployment not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}

///
unittest {
//     auto repo = new IDeploymentRepository();
//     auto usecase = new ManageDeploymentsUseCase(repo);
//     auto tenantId = TenantId("test-tenant");
// 
//     // Test create
//     DeploymentDTO createDto;
//     createDto.tenantId = tenantId;
//     createDto.deploymentId = DeploymentId("deployment-1");
//     createDto.name = "Test Deployment";
//     auto createResult = usecase.createDeployment(createDto);
//     assert(createResult.success, createResult.message);
// 
//     // Test list
//     auto items = usecase.listDeployments(tenantId);
//     assert(items.length == 1);
// 
//     // Test get
//     auto item = usecase.getDeployment(tenantId, DeploymentId("deployment-1"));
//     assert(!item.isNull);
// 
//     // Test update
//     DeploymentDTO updateDto;
//     updateDto.tenantId = tenantId;
//     updateDto.deploymentId = DeploymentId("deployment-1");
//     // updateDto.name = "Updated Deployment";
//     // auto updateResult = usecase.updateDeployment(updateDto);
//     // assert(updateResult.success, updateResult.message);
// 
//     // Test delete
//     // auto deleteResult = usecase.deleteDeployment(tenantId, DeploymentId("deployment-1"));
//     // assert(deleteResult.success, deleteResult.message);
//     // assert(usecase.listDeployments(tenantId).length == 0);

}
