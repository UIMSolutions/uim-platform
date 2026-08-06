/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.deployments;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class DeploymentRepository : TenantRepository!(Deployment, DeploymentId), IDeploymentRepository {

  size_t countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  Deployment[] filterByProject(Deployment[] deployments, string projectId) {
    return deployments.filter!(d => d.projectId.value == projectId).array;
  }

  override Deployment[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void removeByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!(d => remove(d));
  }

  size_t countByEnvironment(TenantId tenantId, DeploymentEnvironment env) {
    return findByEnvironment(tenantId, env).length;
  }

  Deployment[] filterByEnvironment(Deployment[] deployments, DeploymentEnvironment env) {
    return deployments.filter!(d => d.targetEnvironment == env).array;
  }

  Deployment[] findByEnvironment(TenantId tenantId, DeploymentEnvironment env) {
    return filterByEnvironment(findByTenant(tenantId), env);
  }

  void removeByEnvironment(TenantId tenantId, DeploymentEnvironment env) {
    findByEnvironment(tenantId, env).each!(d => remove(d));
  }

  size_t countByStatus(TenantId tenantId, DeploymentStatus status) {
    return findByStatus(tenantId, status).length;
  }

  Deployment[] filterByStatus(Deployment[] deployments, DeploymentStatus status) {
    return deployments.filter!(d => d.status == status).array;
  }

  override Deployment[] findByStatus(TenantId tenantId, DeploymentStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DeploymentStatus status) {
    findByStatus(tenantId, status).each!(d => remove(d));
  }

  size_t countByBuildJob(TenantId tenantId, string buildJobId) {
    return findByBuildJob(tenantId, buildJobId).length;
  }

  Deployment[] filterByBuildJob(Deployment[] deployments, string buildJobId) {
    return deployments.filter!(d => d.buildJobId.value == buildJobId).array;
  }

  Deployment[] findByBuildJob(TenantId tenantId, string buildJobId) {
    return filterByBuildJob(findByTenant(tenantId), buildJobId);
  }

  void removeByBuildJob(TenantId tenantId, string buildJobId) {
    findByBuildJob(tenantId, buildJobId).each!(d => remove(d));
  }
  
}
