/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.ports.repositories.repositories;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Systems are unique by name within a tenant and role.
interface ISystemRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  TEntity findByName(TenantId tenantId, string name);
}

alias ISourceSystemRepository = ISystemRepository!(SourceSystem, SourceSystemId);
alias ITargetSystemRepository = ISystemRepository!(TargetSystem, TargetSystemId);
alias IProxySystemRepository = ISystemRepository!(ProxySystem, ProxySystemId);

interface ITransformationRepository : ITenantRepository!(Transformation, TransformationId) {
  Transformation findByName(TenantId tenantId, string name);
  Transformation[] findBySystem(TenantId tenantId, SystemRole role, string systemId);
}

interface IProvisioningJobRepository : ITenantRepository!(ProvisioningJob, ProvisioningJobId) {
  ProvisioningJob findByName(TenantId tenantId, string name);
  ProvisioningJob[] findBySource(TenantId tenantId, SourceSystemId sourceId);
  ProvisioningJob[] findByTarget(TenantId tenantId, TargetSystemId targetId);
}

interface IProvisioningLogRepository : ITenantRepository!(ProvisioningLog, ProvisioningLogId) {
  /// Entries of a job, newest first.
  ProvisioningLog[] findByJob(TenantId tenantId, ProvisioningJobId jobId);
}

interface IProvisionedEntityRepository : ITenantRepository!(ProvisionedEntity, ProvisionedEntityId) {
  /// The delta state of a (source, target) pair.
  ProvisionedEntity[] findByPair(TenantId tenantId, SourceSystemId sourceId, TargetSystemId targetId);
  ProvisionedEntity[] findByTarget(TenantId tenantId, TargetSystemId targetId);
}
