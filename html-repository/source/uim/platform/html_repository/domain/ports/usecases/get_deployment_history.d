/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.get_deployment_history;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:
interface IGetDeploymentHistoryUseCase {

    DeploymentRecord getRecord(TenantId tenantId, DeploymentRecordId id);

    DeploymentRecord[] listRecords(TenantId tenantId, HtmlAppId appId);

    DeploymentRecord[] listRecords(TenantId tenantId, AppVersionId versionId);

    DeploymentRecord[] listRecords(TenantId tenantId);

}
