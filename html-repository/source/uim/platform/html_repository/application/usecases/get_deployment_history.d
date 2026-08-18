/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.get_deployment_history;
// import uim.platform.html_repository.domain.ports.repositories.deployment_records;
// import uim.platform.html_repository.domain.entities.deployment_record;
// import uim.platform.html_repository.domain.types;
import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
class GetDeploymentHistoryUseCase {
    private IDeploymentRecordRepository repo;

    this(IDeploymentRecordRepository repo) {
        this.repo = repo;
    }

    DeploymentRecord[] getByApp(TenantId tenantId, HtmlAppId appId) {
        return repo.findByApp(tenantId, appId);
    }

    DeploymentRecord[] getByVersion(TenantId tenantId, AppVersionId versionId) {
        return repo.findByVersion(tenantId, versionId);
    }

    DeploymentRecord[] getByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DeploymentRecord getById(TenantId tenantId, DeploymentRecordId id) {
        return repo.findById(tenantId, id);
    }
}
