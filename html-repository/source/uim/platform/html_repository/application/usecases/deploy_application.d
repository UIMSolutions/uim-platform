/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.deploy_application;

// import uim.platform.html_repository.domain.ports.repositories.deployment_records;
// import uim.platform.html_repository.domain.ports.repositories.html_apps;
// import uim.platform.html_repository.domain.ports.repositories.app_versions;
// import uim.platform.html_repository.domain.entities.deployment_record;
// import uim.platform.html_repository.domain.entities.html_app;
// import uim.platform.html_repository.domain.entities.app_version;
// import uim.platform.html_repository.domain.services.deployment_validator;
// import uim.platform.html_repository.domain.types;
// import uim.platform.html_repository.application.dto;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

class DeployApplicationUseCase { // TODO: UIMUseCase {
    private IDeploymentRecordRepository deploymentRepo;
    private IHtmlAppRepository appRepo;
    private IAppVersionRepository versionRepo;

    this(IDeploymentRecordRepository deploymentRepo, IHtmlAppRepository appRepo, IAppVersionRepository versionRepo) {
        this.deploymentRepo = deploymentRepo;
        this.appRepo = appRepo;
        this.versionRepo = versionRepo;
    }

    CommandResult deploy(CreateDeploymentRequest r) {
        auto app = appRepo.findById(r.tenantId, r.appId);
        if (app.isNull)
            return CommandResult(false, "", "App not found");

        auto version_ = versionRepo.findById(r.tenantId, r.versionId);
        if (version_.isNull)
            return CommandResult(false, "", "Version not found");

        auto record = DeploymentRecord(r.tenantId);
        record.appId = r.appId;
        record.versionId = r.versionId;
        record.serviceInstanceId = r.instanceId;
        record.operation = r.operation.toDeploymentOperation;
        record.status = DeploymentStatus.completed;
        record.startedAt = record.createdAt;
        record.completedAt = record.createdAt;
        record.deployedBy = r.deployedBy;

        deploymentRepo.save(record);

        // Update app's active version
        app.activeVersionId = r.versionId;
        app.updatedAt = record.createdAt;
        appRepo.update(app);

        // Mark version as active
        version_.status = VersionStatus.active;
        version_.deployedAt = record.createdAt;

        versionRepo.update(version_);
        return CommandResult(true, record.id.value, "");
    }

    DeploymentRecord getRecord(TenantId tenantId, DeploymentRecordId id) {
        return deploymentRepo.findById(tenantId, id);
    }

    DeploymentRecord[] listRecords(TenantId tenantId, HtmlAppId appId) {
        return deploymentRepo.findByApp(tenantId, appId);
    }

    DeploymentRecord[] listRecords(TenantId tenantId) {
        return deploymentRepo.findByTenant(tenantId);
    }

    size_t countRecords(TenantId tenantId) {
        return deploymentRepo.countByTenant(tenantId);
    }

}
