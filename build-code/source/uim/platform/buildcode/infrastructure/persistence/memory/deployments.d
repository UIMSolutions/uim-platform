/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.memory.deployments;

import uim.platform.buildcode;

// mixin(ShowModule!());

@safe:

class MemoryDeploymentRepository : DeploymentRepository {
  private Deployment[string] _store;

  override void save(Deployment entity)                { _store[entity.id.value] = entity; }
  override void update(Deployment entity)              { _store[entity.id.value] = entity; }
  override void remove(TenantId tenantId, DeploymentId id) { _store.remove(id.value); }

  override Deployment findById(TenantId tenantId, DeploymentId id) {
    if (id.value in _store) return _store[id.value];
    Deployment d; return d;
  }

  override Deployment[] findByTenant(TenantId tenantId) {
    Deployment[] result;
    foreach (d; _store.byValue)
      if (d.tenantId == tenantId) result ~= d;
    return result;
  }

  override Deployment[] findByProject(TenantId tenantId, string projectId) {
    Deployment[] result;
    foreach (d; _store.byValue)
      if (d.tenantId == tenantId && d.projectId.value == projectId) result ~= d;
    return result;
  }

  override Deployment[] findByEnvironment(TenantId tenantId, DeploymentEnvironment env) {
    Deployment[] result;
    foreach (d; _store.byValue)
      if (d.tenantId == tenantId && d.targetEnvironment == env) result ~= d;
    return result;
  }

  override Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    Deployment[] result;
    foreach (d; _store.byValue)
      if (d.tenantId == tenantId && d.status == status) result ~= d;
    return result;
  }

  override Deployment[] findByBuildJob(TenantId tenantId, string buildJobId) {
    Deployment[] result;
    foreach (d; _store.byValue)
      if (d.tenantId == tenantId && d.buildJobId.value == buildJobId) result ~= d;
    return result;
  }
}
