/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.projects;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class ProjectRepository : TenantRepository!(Project, ProjectId), IProjectRepository {

  size_t countByStatus(TenantId tenantId, ProjectStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Project[] filterByStatus(Project[] projects, ProjectStatus status) {
    return projects.filter!(p => p.status == status).array;
  }

  Project[] findByStatus(TenantId tenantId, ProjectStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ProjectStatus status) {
    findByStatus(tenantId, status).each!(p => remove(p));
  }

  size_t countByType(TenantId tenantId, ProjectType type) {
    return findByType(tenantId, type).length;
  }

  Project[] filterByType(Project[] projects, ProjectType type) {
    return projects.filter!(p => p.type == type).array;
  }

  Project[] findByType(TenantId tenantId, ProjectType type) {
    return filterByType(findByTenant(tenantId), type);
  }

  void removeByType(TenantId tenantId, ProjectType type) {
    findByType(tenantId, type).each!(p => remove(p));
  }

  size_t countByOwner(TenantId tenantId, string ownerEmail) {
    return findByOwner(tenantId, ownerEmail).length;
  }

  Project[] filterByOwner(Project[] projects, string ownerEmail) {
    return projects.filter!(p => p.ownerEmail == ownerEmail).array;
  }

  Project[] findByOwner(TenantId tenantId, string ownerEmail) {
    return filterByOwner(findByTenant(tenantId), ownerEmail);
  }

  void removeByOwner(TenantId tenantId, string ownerEmail) {
    findByOwner(tenantId, ownerEmail).each!(p => remove(p));
  }

  bool nameExists(TenantId tenantId, string name) {
    return findByTenant(tenantId).any!(p => p.name == name);
  }
}
