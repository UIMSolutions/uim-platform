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

    CommandResult createRepository(RepositoryDTO dto);

    CommandResult updateRepository(RepositoryDTO dto);

    CommandResult activateRepository(TenantId tenantId, RepositoryId id);

    CommandResult deactivateRepository(TenantId tenantId, RepositoryId id);

    CommandResult deleteRepository(TenantId tenantId, RepositoryId id);

}
