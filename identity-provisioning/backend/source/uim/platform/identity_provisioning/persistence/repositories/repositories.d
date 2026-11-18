/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_provisioning.persistence.repositories.repositories;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// Systems of one role; unique by name.
class SystemRepository(TEntity, TId) : ProvisioningRepository!(TEntity, TId), ISystemRepository!(TEntity, TId) {
  this() {
    super();
  }

  this(ITenantStore!(TEntity, TId) store) {
    super(store);
  }

  TEntity findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }
}

alias SourceSystemRepository = SystemRepository!(SourceSystem, SourceSystemId);
alias TargetSystemRepository = SystemRepository!(TargetSystem, TargetSystemId);
alias ProxySystemRepository = SystemRepository!(ProxySystem, ProxySystemId);

class TransformationRepository : ProvisioningRepository!(Transformation, TransformationId), ITransformationRepository {
  this() {
    super();
  }

  this(ITenantStore!(Transformation, TransformationId) store) {
    super(store);
  }

  Transformation findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  Transformation[] findBySystem(TenantId tenantId, SystemRole role, string systemId) {
    return where(tenantId, (e) => e.systemRole == role && e.systemId == systemId);
  }
}

class ProvisioningJobRepository : ProvisioningRepository!(ProvisioningJob, ProvisioningJobId), IProvisioningJobRepository {
  this() {
    super();
  }

  this(ITenantStore!(ProvisioningJob, ProvisioningJobId) store) {
    super(store);
  }

  ProvisioningJob findByName(TenantId tenantId, string name) {
    return first(tenantId, (e) => e.name == name);
  }

  ProvisioningJob[] findBySource(TenantId tenantId, SourceSystemId sourceId) {
    return where(tenantId, (e) => e.sourceSystemId == sourceId);
  }

  ProvisioningJob[] findByTarget(TenantId tenantId, TargetSystemId targetId) {
    return where(tenantId, (e) => e.targetSystemId == targetId);
  }
}

class ProvisioningLogRepository : ProvisioningRepository!(ProvisioningLog, ProvisioningLogId), IProvisioningLogRepository {
  this() {
    super();
  }

  this(ITenantStore!(ProvisioningLog, ProvisioningLogId) store) {
    super(store);
  }

  ProvisioningLog[] findByJob(TenantId tenantId, ProvisioningJobId jobId) {
    auto result = where(tenantId, (e) => e.jobId == jobId);
    result.sort!((a, b) => a.createdAt > b.createdAt);
    return result;
  }
}

class ProvisionedEntityRepository : ProvisioningRepository!(ProvisionedEntity, ProvisionedEntityId),
  IProvisionedEntityRepository {
  this() {
    super();
  }

  this(ITenantStore!(ProvisionedEntity, ProvisionedEntityId) store) {
    super(store);
  }

  ProvisionedEntity[] findByPair(TenantId tenantId, SourceSystemId sourceId, TargetSystemId targetId) {
    return where(tenantId, (e) => e.sourceSystemId == sourceId && e.targetSystemId == targetId);
  }

  ProvisionedEntity[] findByTarget(TenantId tenantId, TargetSystemId targetId) {
    return where(tenantId, (e) => e.targetSystemId == targetId);
  }
}

///
unittest {
  mixin(ShowTest!("Repositories"));

  assert(tenantRepositoryTest(new SourceSystemRepository()));
  assert(tenantRepositoryTest(new TargetSystemRepository()));
  assert(tenantRepositoryTest(new ProxySystemRepository()));
  assert(tenantRepositoryTest(new TransformationRepository()));
  assert(tenantRepositoryTest(new ProvisioningJobRepository()));
  assert(tenantRepositoryTest(new ProvisioningLogRepository()));
  assert(tenantRepositoryTest(new ProvisionedEntityRepository()));

  auto t = TenantId("t1");
  auto transformations = new TransformationRepository();
  auto x = Transformation(t);
  x.name = "map";
  x.systemRole = SystemRole.source;
  x.systemId = "s1";
  transformations.save(x);
  assert(transformations.findBySystem(t, SystemRole.source, "s1").length == 1);
  assert(transformations.findBySystem(t, SystemRole.target, "s1").length == 0);
  assert(!transformations.findByName(t, "map").isNull);

  auto entities = new ProvisionedEntityRepository();
  auto e = ProvisionedEntity(t);
  e.sourceSystemId = SourceSystemId("s1");
  e.targetSystemId = TargetSystemId("t1");
  entities.save(e);
  assert(entities.findByPair(t, SourceSystemId("s1"), TargetSystemId("t1")).length == 1);
  assert(entities.findByPair(t, SourceSystemId("s2"), TargetSystemId("t1")).length == 0);
}
