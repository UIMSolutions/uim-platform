/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.infrastructure.persistence.repositories.build_jobs;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

class BuildJobRepository : TenantRepository!(BuildJob, BuildJobId), IBuildJobRepository {

  size_t countByPipeline(TenantId tenantId, string pipelineId) {
    return findByPipeline(tenantId, pipelineId).length;
  }

  BuildJob[] filterByPipeline(BuildJob[] jobs, string pipelineId) {
    return jobs.filter!(j => j.pipelineId.value == pipelineId).array;
  }

  BuildJob[] findByPipeline(TenantId tenantId, string pipelineId) {
    return filterByPipeline(findByTenant(tenantId), pipelineId);
  }

  void removeByPipeline(TenantId tenantId, string pipelineId) {
    findByPipeline(tenantId, pipelineId).each!(j => remove(j));
  }

  size_t countByProject(TenantId tenantId, string projectId) {
    return findByProject(tenantId, projectId).length;
  }

  BuildJob[] filterByProject(BuildJob[] jobs, string projectId) {
    return jobs.filter!(j => j.projectId.value == projectId).array;
  }

  BuildJob[] findByProject(TenantId tenantId, string projectId) {
    return filterByProject(findByTenant(tenantId), projectId);
  }

  void removeByProject(TenantId tenantId, string projectId) {
    findByProject(tenantId, projectId).each!(j => remove(j));
  }

  size_t countByStatus(TenantId tenantId, JobStatus status) {
    return findByStatus(tenantId, status).length;
  }

  BuildJob[] filterByStatus(BuildJob[] jobs, JobStatus status) {
    return jobs.filter!(j => j.status == status).array;
  }

  BuildJob[] findByStatus(TenantId tenantId, JobStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, JobStatus status) {
    findByStatus(tenantId, status).each!(j => remove(j));
  }

  size_t countByBranch(TenantId tenantId, string branch) {
    return findByBranch(tenantId, branch).length;
  }

  BuildJob[] filterByBranch(BuildJob[] jobs, string branch) {
    return jobs.filter!(j => j.branch == branch).array;
  }

  BuildJob[] findByBranch(TenantId tenantId, string branch) {
    return filterByBranch(findByTenant(tenantId), branch);
  }

  void removeByBranch(TenantId tenantId, string branch) {
    findByBranch(tenantId, branch).each!(j => remove(j));
  }
  
}
