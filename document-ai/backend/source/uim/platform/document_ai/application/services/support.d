/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Helpers shared by the interactors: the policy, auditing, references and
/// the generic resource interactor (create / PATCH / get / list / delete
/// with validation, immutable attributes and events).
module uim.platform.document_ai.application.services.support;

import std.traits : FieldNameTuple;
import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

/// Business limits and switches of the interactors (from the configuration).
struct DaiPolicy {
  bool processImmediately; /// extract on upload (no background worker)
  double minConfidence = 0.7; /// values below need a review
  int minTrainingDocuments = 3; /// confirmed documents a training job needs
  long trainingSeconds = 30; /// simulated training time
  size_t maxDocumentsPerRun = 50; /// worker: documents per run
  int maxFailedLogins = 5; /// failed logins before a temporary lock
  long lockSeconds = 900; /// duration of the temporary lock
  size_t minPasswordLength = 10;
}

/// Actor of the background worker.
enum string workerActor = "worker";

/// Return the entity or throw notFound.
T required(T)(T entity, lazy string what) {
  if (entity.isNull)
    throw DaiException.notFound(what);
  return entity;
}

/// Initialise id, tenant and audit fields of a new entity.
void stampCreated(E, TId)(ref E entity, TenantId tenantId, UserId actor, string id, long now) {
  if (tenantId.isNull)
    throw DaiException.invalid("Tenant is required");
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

/// Base class of all interactors: repositories, clock, events, unit of work and policy.
abstract class DaiInteractor {
  protected DaiRepositories repos;
  protected IClock clock;
  protected IDaiEventPublisher events;
  protected IDaiUnitOfWork unitOfWork;
  protected DaiPolicy policy;
  private long lastTime; /// strictly increasing creation times keep lists in order

  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    this.repos = repos;
    this.clock = clock;
    this.events = events !is null ? events : new NullEventPublisher;
    this.unitOfWork = unitOfWork !is null ? unitOfWork : new ImmediateDaiUnitOfWork;
    this.policy = policy;
  }

  protected long now() {
    return clock.now();
  }

  /// A creation time after the previous one of this interactor (stable order).
  protected long nextTime() {
    auto at = now;
    if (at <= lastTime)
      at = lastTime + 1;
    lastTime = at;
    return at;
  }

  protected void emit(string type, TenantId t, string subject, Json data = Json.emptyObject) {
    events.publish(type, t, subject, data);
  }

  protected void batch(scope void delegate() @safe work) {
    unitOfWork.batch(work);
  }

  /// An optional reference: "" stays empty, anything else must exist.
  protected string optionalReference(TId, R)(R repo, TenantId t, string id, string what) {
    auto v = id.strip;
    if (v.length == 0)
      return "";
    if (!repo.existsById(t, TId(v)))
      throw DaiException.notFound(what ~ " '" ~ v ~ "'");
    return v;
  }

  /// Refuse an operation while references exist ("… is used by 3 documents").
  protected void requireUnused(string what, long count, string users) {
    if (count > 0)
      throw DaiException.ruleViolation(format("%s is still used by %d %s", what, count, users));
  }

  /// The schema or notFound.
  protected Schema schemaOf(TenantId t, SchemaId id) {
    if (id.isNull)
      throw DaiException.invalid("Schema is required");
    return required(repos.schemas.findById(t, id), "Schema '" ~ id.value ~ "'");
  }

  /// Recompute the summary and the enrichment match of a document.
  protected void refreshSummary(TenantId t, ref AiDocument doc, const ExtractedField[] fields) {
    auto s = summarize(fields, policy.minConfidence);
    doc.overallConfidence = s.overall;
    doc.extractedFieldCount = s.fields;
    doc.lineItemCount = s.lineItems;
    doc.lowConfidenceCount = s.low;
    doc.correctedFieldCount = s.corrected;
    EnrichmentData[] candidates;
    foreach (e; repos.enrichmentData.findAll(t))
      if (e.appliesTo(doc.clientId, doc.documentTypeId))
        candidates ~= e;
    if (candidates.length == 0) {
      doc.matchStatus = MatchStatus.notChecked;
      doc.matchedEnrichmentId = EnrichmentDataId.init;
      doc.matchScore = 0;
      return;
    }
    auto m = matchEnrichment(fields, candidates);
    doc.matchStatus = m.status;
    doc.matchedEnrichmentId = m.matchedId;
    doc.matchScore = m.score;
  }

  protected ExtractedField[] valuesOf(TenantId t, DocumentId document) {
    auto fields = repos.extractedFields.findByReference(t, "documentId", document.value);
    fields.sort!((a, b) => a.rowIndex != b.rowIndex ? a.rowIndex < b.rowIndex
        : a.sequenceNumber != b.sequenceNumber ? a.sequenceNumber < b.sequenceNumber : a.name < b.name);
    return fields;
  }

  /// The fields of a schema: header first, then line items, each in sequence.
  protected SchemaField[] fieldsOf(TenantId t, SchemaId id) {
    auto fields = repos.schemaFields.findByReference(t, "schemaId", id.value);
    fields.sort!((a, b) => a.fieldScope != b.fieldScope ? a.fieldScope == FieldScope.header
        : a.sequenceNumber != b.sequenceNumber ? a.sequenceNumber < b.sequenceNumber : a.name < b.name);
    return fields;
  }
}

/// Generic interactor of a maintained resource. Subclasses map the input
/// onto the entity (fromInput/toInput) and add reference checks.
abstract class ResourceInteractor(TEntity, TId, TInput) : DaiInteractor, IManageResource!(TEntity, TId, TInput) {
  this(DaiRepositories repos, IClock clock, IDaiEventPublisher events, IDaiUnitOfWork unitOfWork, DaiPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  protected abstract IDaiRepository!(TEntity, TId) store();
  /// "Schema" (messages)
  protected abstract string what();
  /// "schema" (events)
  protected abstract string eventPrefix();
  protected abstract TInput toInput(const TEntity e);
  /// Map (parse, check references); creating = false for updates.
  protected abstract void fromInput(TenantId t, ref TEntity e, TInput input, bool creating);

  /// Input members that cannot change after creation.
  protected string[] immutableAttributes() {
    return null;
  }

  /// Checks before a change (e.g. frozen entities).
  protected void beforeUpdate(TenantId t, const TEntity e) {
  }

  /// Follow-up after create (inside no batch).
  protected TEntity afterCreate(TenantId t, TEntity e, UserId actor) {
    return e;
  }

  /// Reference checks and cascades (inside the batch of the removal).
  protected void beforeRemove(TenantId t, const TEntity e, UserId actor) {
  }

  TEntity create(CreateCommand!TInput c) {
    auto id = idOrNew(c.id, what ~ " ID");
    if (store.existsById(c.tenantId, TId(id)))
      throw DaiException.conflict(what ~ " '" ~ id ~ "' already exists");
    TInput input;
    c.input.applyTo(input);
    TEntity e;
    stampCreated!(TEntity, TId)(e, c.tenantId, c.actor, id, nextTime);
    fromInput(c.tenantId, e, input, true);
    e.validate();
    store.save(e);
    emit(eventPrefix ~ ".created", c.tenantId, id);
    return afterCreate(c.tenantId, e, c.actor);
  }

  TEntity update(UpdateCommand!TInput c) @trusted {
    auto e = get(c.tenantId, TId(c.id));
    beforeUpdate(c.tenantId, e);
    auto before = toInput(e);
    auto after = before;
    c.changes.applyTo(after);
    auto fixed = immutableAttributes;
    static foreach (name; FieldNameTuple!TInput)
      if (fixed.canFind(name) && __traits(getMember, after, name) != __traits(getMember, before, name))
        throw DaiException.invalid("'" ~ name ~ "' of " ~ what.toLower ~ " '" ~ c.id ~ "' cannot be changed");
    fromInput(c.tenantId, e, after, false);
    e.validate();
    stampUpdated(e, c.actor, now);
    store.save(e);
    emit(eventPrefix ~ ".updated", c.tenantId, c.id, Json(["fields": Json(c.changes.fields.join(","))]));
    return e;
  }

  TEntity get(TenantId t, TId id) {
    return required(store.findById(t, id), what ~ " '" ~ id.value ~ "'");
  }

  TEntity[] list(TenantId t) {
    return store.findAll(t);
  }

  void remove(TenantId t, TId id, UserId actor) {
    auto e = get(t, id);
    batch(() {
      beforeRemove(t, e, actor);
      store.removeById(t, id);
    });
    emit(eventPrefix ~ ".deleted", t, id.value, Json(["by": Json(actor.value)]));
  }
}
