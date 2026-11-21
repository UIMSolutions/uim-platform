/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors.
module uim.platform.data_quality.application.services.support;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct DqPolicy {
  bool autoValidate = true; /// validate records when they are created or changed
  size_t maxSnapshots = 100; /// trend points kept per dataset
  size_t maxImportRecords = 50_000; /// records per import request
  size_t maxPairwiseRecords = 20_000; /// fuzzy/composite duplicate detection limit
  bool runJobsImmediately; /// run cleansing jobs on creation (no background worker)
}

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw DataQualityException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw DataQualityException.invalid("Tenant is required");
  entity.id = TId(id);
  entity.tenantId = tenantId;
  entity.createdAt = now;
  entity.updatedAt = now;
  entity.createdBy = actor;
  entity.updatedBy = actor;
}

/// Refresh the audit fields of a changed entity.
void stampUpdated(E)(ref E entity, UserId actor, long now) {
  entity.updatedAt = now;
  entity.updatedBy = actor;
}

/// A requested id, or a generated one.
string idOrNew(string requested, string what = "ID") {
  auto id = requested.strip;
  if (id.length == 0)
    return newResourceId();
  requireId(id, what);
  return id;
}

/// Base class of all interactors: repositories, clock, events, unit of work and policy.
abstract class DqInteractor {
  protected DqRepositories repos;
  protected IClock clock;
  protected IDqEventPublisher events;
  protected IDqUnitOfWork unitOfWork;
  protected DqPolicy policy;

  this(DqRepositories repos, IClock clock, IDqEventPublisher events, IDqUnitOfWork unitOfWork, DqPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateDqUnitOfWork;
    this.policy = policy;
  }

  protected long now() {
    return clock.now();
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  protected Dataset datasetOf(TenantId t, DatasetId ds) {
    if (ds.isNull)
      throw DataQualityException.invalid("Dataset is required");
    return required(repos.datasets.findById(t, ds), "Dataset '" ~ ds.value ~ "'");
  }

  protected DataRecord recordOf(TenantId t, DatasetId ds, RecordId id) {
    return required(repos.records.findById(t, ds, id), "Record '" ~ id.value ~ "' of dataset '" ~ ds.value ~ "'");
  }
}

///
unittest {
  assert(idOrNew("").length == 16 && idOrNew("my-id") == "my-id");
  assert(failsWith(DqErrorKind.invalid, () { idOrNew("a~b"); }));
}
