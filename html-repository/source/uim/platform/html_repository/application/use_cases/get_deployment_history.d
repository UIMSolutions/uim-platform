/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.application.usecases.get_deployment_history;

import uim.platform.html_repository.domain.ports.deployment_record_repository;
import uim.platform.html_repository.domain.entities.deployment_record;
import uim.platform.html_repository.domain.types;

class GetDeploymentHistoryUseCase : UIMUseCase {
    private DeploymentRecordRepository repo;

    this(DeploymentRecordRepository repo) {
        this.repo = repo;
    }

    DeploymentRecord[] getByApp(HtmlAppId appId) {
        return repo.findByApp(appId);
    }

    DeploymentRecord[] getByVersion(AppVersionId versionId) {
        return repo.findByVersion(versionId);
    }

    DeploymentRecord[] getByTenant(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    DeploymentRecord get_(DeploymentRecordId id) {
        return repo.findById(id);
    }
}
