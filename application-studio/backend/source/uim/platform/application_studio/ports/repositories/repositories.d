/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.ports.repositories.repositories;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Persistence of tenant-wide aggregates with unique names (catalogue, dev spaces).
interface INamedRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity findByName(TenantId tenantId, string name);
}

interface IDevSpaceTypeRepository : INamedRepository!(DevSpaceType, DevSpaceTypeId) {
}

interface IExtensionRepository : INamedRepository!(Extension, ExtensionId) {
}

interface IProjectTemplateRepository : INamedRepository!(ProjectTemplate, ProjectTemplateId) {
}

interface IDevSpaceRepository : INamedRepository!(DevSpace, DevSpaceId) {
  DevSpace[] findByType(TenantId tenantId, DevSpaceTypeId typeId);
  /// Dev spaces that have `extension` among their additional extensions.
  DevSpace[] findByExtension(TenantId tenantId, string extension);
}

/// Persistence of aggregates that live inside one dev space (names unique per dev space).
interface IDevSpaceScopedRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity findByName(TenantId tenantId, DevSpaceId devSpaceId, string name);
  TEntity[] findByDevSpace(TenantId tenantId, DevSpaceId devSpaceId);
}

interface IProjectRepository : IDevSpaceScopedRepository!(Project, ProjectId) {
  Project[] findByTemplate(TenantId tenantId, ProjectTemplateId templateId);
}

interface IServiceBindingRepository : IDevSpaceScopedRepository!(ServiceBinding, ServiceBindingId) {
}

/// Persistence of aggregates that live inside one project (names unique per project).
interface IProjectScopedRepository(TEntity, TId) : IDevSpaceScopedRepository!(TEntity, TId) {
  TEntity findByProjectAndName(TenantId tenantId, ProjectId projectId, string name);
  TEntity[] findByProject(TenantId tenantId, ProjectId projectId);
}

interface IRunConfigurationRepository : IProjectScopedRepository!(RunConfiguration, RunConfigurationId) {
}

interface IBuildConfigurationRepository : IProjectScopedRepository!(BuildConfiguration, BuildConfigurationId) {
}
