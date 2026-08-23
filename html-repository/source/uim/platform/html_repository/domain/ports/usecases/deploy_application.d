/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.ports.usecases.deploy_application;

import uim.platform.html_repository;

mixin(ShowModule!());

@safe:

interface IDeployApplicationUseCase {

    UsecaseResult deploy(CreateDeploymentRequest r);

    DeploymentRecord getRecord(TenantId tenantId, DeploymentRecordId id);

    DeploymentRecord[] listRecords(TenantId tenantId, HtmlAppId appId);

    DeploymentRecord[] listRecords(TenantId tenantId);

    size_t countRecords(TenantId tenantId);

}
