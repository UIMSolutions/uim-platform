/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.deploy_application;

import uim.platform.html_repository.domain.ports.repositories.deployment_records;
import uim.platform.html_repository.domain.ports.repositories.html_apps;
import uim.platform.html_repository.domain.ports.repositories.app_versions;
import uim.platform.html_repository.domain.entities.deployment_record;
import uim.platform.html_repository.domain.entities.html_app;
import uim.platform.html_repository.domain.entities.app_version;
import uim.platform.html_repository.domain.services.deployment_validator;
import uim.platform.html_repository.domain.types;
import uim.platform.html_repository.application.dto;

import std.uuid : randomUUID;
import std.conv : to;

class DeployApplicationUseCase : UIMUseCase {
    private DeploymentRecordRepository deploymentRepo;
    private HtmlAppRepository appRepo;
    private AppVersionRepository versionRepo;

    this(DeploymentRecordRepository deploymentRepo, HtmlAppRepository appRepo, AppVersionRepository versionRepo) {
        this.deploymentRepo = deploymentRepo;
        this.appRepo = appRepo;
        this.versionRepo = versionRepo;
    }

    CommandResult deploy(CreateDeploymentRequest r) {
        auto app = appRepo.findById(r.appId);
        if (app.id.isEmpty)
            return CommandResult(false, "", "App not found");

        auto version_ = versionRepo.findById(r.versionId);
        if (version_.id.isEmpty)
            return CommandResult(false, "", "Version not found");

        DeploymentRecord record;
        record.id = randomUUID().to!string;
        record.tenantId = r.tenantId;
        record.appId = r.appId;
        record.versionId = r.versionId;
        record.serviceInstanceId = r.serviceInstanceId;
        record.operation = parseOperation(r.operation);
        record.status = DeploymentStatus.completed;
        record.startedAt = currentTimestamp();
        record.completedAt = currentTimestamp();
        record.createdAt = currentTimestamp();
        record.deployedBy = r.deployedBy;

        deploymentRepo.save(record);

        // Update app's active version
        app.activeVersionId = r.versionId;
        app.updatedAt = currentTimestamp();
        appRepo.update(app);

        // Mark version as active
        version_.status = VersionStatus.active;
        version_.deployedAt = currentTimestamp();
        versionRepo.update(version_);

        return CommandResult(true, record.id, "");
    }

    DeploymentRecord get_(DeploymentRecordId id) {
        return deploymentRepo.findById(id);
    }

    DeploymentRecord[] listByApp(HtmlAppId appId) {
        return deploymentRepo.findByApp(appId);
    }

    DeploymentRecord[] listByTenant(TenantId tenantId) {
        return deploymentRepo.findByTenant(tenantId);
    }

    long countByTenant(TenantId tenantId) {
        return deploymentRepo.countByTenant(tenantId);
    }

    private static DeploymentOperation parseOperation(string op) {
        switch (op) {
            case "deploy": return DeploymentOperation.deploy;
            case "undeploy": return DeploymentOperation.undeploy;
            case "redeploy": return DeploymentOperation.redeploy;
            default: return DeploymentOperation.deploy;
        }
    }

    private static long currentTimestamp() {
        import std.datetime.systime : Clock;
        return Clock.currStdTime();
    }
}
