/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.transport_requests;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Interactor: transport requests. Tasks must be released before the request;
/// released requests are imported into their target system by the reconciler.
class ManageTransportRequestsUseCase
  : ResourceUseCase!(TransportRequest, TransportRequestId, CreateTransportRequestRequest, UpdateTransportRequestRequest),
  IManageTransportRequestsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.transportRequests, publisher, "Transport request", "abap.transport-request");
  }

  override protected TransportRequest build(CreateTransportRequestRequest r) {
    auto source = requireActiveSystem(r.tenantId, r.parentId, "record changes");
    auto t = TransportRequest(r.tenantId);
    t.sourceSystemId = source.id;
    t.sourceSystemName = source.name;
    assignMatching(t, r.spec);
    check(t);

    auto existing = repos.transportRequests.findBySystem(r.tenantId, source.id).map!(x => x.name).array;
    size_t sequence = existing.length + 1;
    while (existing.canFind(transportNumber(source.sapSystemId, sequence)))
      sequence++;
    t.name = transportNumber(source.sapSystemId, sequence);
    t.status = TransportStatus.modifiable;
    return t;
  }

  override protected void apply(ref TransportRequest t, TransportRequestSpec spec) {
    requireModifiable(t);
    assignMatching(t, spec);
    check(t);
  }

  protected void check(ref TransportRequest t) {
    validate(t.description.strip.length > 0, "Transport request description is required");
    validate(t.owner.strip.length > 0, "Transport request owner is required");
    validate(t.description.length <= 60, "Transport request description must not exceed 60 characters");
    t.targetSystemName = "";
    if (!t.targetSystemId.isEmpty) {
      validate(t.targetSystemId != t.sourceSystemId, "Source and target system must differ");
      auto target = requireSystem(t.tenantId, t.targetSystemId, "targetSystemId");
      t.targetSystemName = target.name;
    }
  }

  protected static void requireModifiable(const ref TransportRequest t) {
    ensureState(t.status == TransportStatus.modifiable, "Transport request " ~ t.name ~ " is not modifiable ("
        ~ enumText(t.status) ~ ")");
  }

  override protected void beforeRemove(TransportRequest t) {
    ensureState(t.status == TransportStatus.modifiable, "Only modifiable transport requests can be deleted");
  }

  UsecaseResult addTask(TenantId tenantId, TransportRequestId id, string owner, string description,
      string[] objects, UserId actor) {
    return transition(tenantId, id, actor, "task added", (ref TransportRequest t) {
      requireModifiable(t);
      foreach (o; objects) {
        auto parts = o.split!(c => c == ' ').filter!(p => p.length > 0).array;
        validate(parts.length == 3 && (parts[0] == "R3TR" || parts[0] == "LIMU"),
          "Object '" ~ o ~ "' must look like 'R3TR CLAS ZCL_TRAVEL'");
      }
      TransportTask task;
      task.taskId = taskNumber(t.name, t.tasks.length);
      task.owner = owner.strip.length > 0 ? owner.strip : t.owner;
      task.description = description.strip.length > 0 ? description.strip : t.description;
      task.objects = objects.map!(o => o.strip).array;
      task.createdAt = nowStdTime();
      t.tasks ~= task;
    });
  }

  UsecaseResult releaseTask(TenantId tenantId, TransportRequestId id, string taskId, UserId actor) {
    return transition(tenantId, id, actor, "task released", (ref TransportRequest t) {
      requireModifiable(t);
      auto i = taskIndex(t, taskId.strip);
      ensureState(t.tasks[i].status == TransportStatus.modifiable, "Task " ~ t.tasks[i].taskId ~ " is already released");
      ensureState(t.tasks[i].owner.length > 0, "Task " ~ t.tasks[i].taskId ~ " needs an owner");
      ensureState(t.tasks[i].objects.length > 0, "Task " ~ t.tasks[i].taskId ~ " contains no objects");
      t.tasks[i].status = TransportStatus.released;
      t.tasks[i].releasedAt = nowStdTime();
    });
  }

  UsecaseResult release(TenantId tenantId, TransportRequestId id, UserId actor) {
    return transition(tenantId, id, actor, "released", (ref TransportRequest t) {
      ensureReleasable(t);
      t.status = TransportStatus.released;
      t.releasedAt = nowStdTime();
      t.statusMessage = "";
    });
  }

  UsecaseResult import_(TenantId tenantId, TransportRequestId id, UserId actor) {
    return transition(tenantId, id, actor, "import queued", (ref TransportRequest t) {
      ensureState(t.status == TransportStatus.released || t.status == TransportStatus.error,
        "Transport request " ~ t.name ~ " must be released before the import (" ~ enumText(t.status) ~ ")");
      ensureState(!t.targetSystemId.isEmpty, "Transport request " ~ t.name ~ " has no target system");
      requireSystem(tenantId, t.targetSystemId, "targetSystemId");
      t.status = TransportStatus.importing;
      t.statusMessage = "Import into " ~ t.targetSystemName ~ " queued";
    });
  }
}
