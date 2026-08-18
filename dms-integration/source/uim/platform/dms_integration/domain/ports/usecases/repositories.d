/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.ports.usecases.repositories;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

interface IManageRepositoriesUseCase {

    Repository_ getRepository(TenantId tenantId, RepositoryId id);

    Repository_[] listRepositories(TenantId tenantId);

    Repository_[] listRepositoriesByStatus(TenantId tenantId, RepositoryStatus status);

    Repository_[] listRepositoriesByType(TenantId tenantId, RepositoryType repositoryType);

    Repository_[] listDefaultRepositories(TenantId tenantId);

    UsecaseResult createRepository(RepositoryDTO dto);

    UsecaseResult updateRepository(RepositoryDTO dto);

    UsecaseResult activateRepository(TenantId tenantId, RepositoryId id);

    UsecaseResult deactivateRepository(TenantId tenantId, RepositoryId id);

    UsecaseResult deleteRepository(TenantId tenantId, RepositoryId id);

}
