/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Deletion requests (right to erasure / restriction of processing).
///
/// Processing a request:
///   block             → the data subject is blocked
///   delete, anonymize → destroyed if the retention expired or no retention
///                       obligation (retention period > 0) applies, e.g.
///                       consent based data; otherwise the data subject is
///                       blocked and the request is rejected with the
///                       earliest possible deletion date
///   legal hold        → rejected (the data subject is blocked)
module uim.platform.data_retention.application.usecases.deletion_requests;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDeletionRequestsUseCase : DrInteractor, IManageDeletionRequests {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  DeletionRequest create(CreateDeletionRequestCommand c) {
    auto id = idOrNew(c.id, "Deletion request ID");
    if (repos.deletionRequests.existsById(c.tenantId, DeletionRequestId(id)))
      throw DataRetentionException.conflict("Deletion request '" ~ id ~ "' already exists");
    auto s = dataSubjectOf(c.tenantId, c.dataSubjectId);
    if (s.isDeleted)
      throw DataRetentionException.ruleViolation("Data subject '" ~ s.id.value ~ "' is already destroyed");
    foreach (other; repos.deletionRequests.findByReference(c.tenantId, "dataSubjectId", s.id.value))
      if (other.isPending)
        throw DataRetentionException.conflict("Data subject '" ~ s.id.value ~ "' already has the pending deletion request '"
            ~ other.id.value ~ "'");
    DeletionRequest r;
    stampCreated!(DeletionRequest, DeletionRequestId)(r, c.tenantId, c.actor, id, now);
    r.dataSubjectId = s.id;
    r.applicationGroupId = s.applicationGroupId;
    r.action = parseDomainEnumOr!DeletionAction(c.action, DeletionAction.delete_, "action");
    r.reason = c.reason.strip;
    r.validate();
    repos.deletionRequests.save(r);
    emit("deletionRequest.created", c.tenantId, id, Json(["dataSubjectId": Json(s.id.value),
        "action": Json(cast(string) r.action)]));
    return policy.processRequestsImmediately ? process(c.tenantId, r.id, c.actor) : r;
  }

  DeletionRequest process(TenantId t, DeletionRequestId id, UserId actor) {
    auto r = get(t, id);
    if (!r.isPending)
      throw DataRetentionException.ruleViolation("Deletion request '" ~ id.value ~ "' is already " ~ cast(string) r.status);
    auto at = now;
    batch(() {
      auto s = repos.dataSubjects.findById(t, r.dataSubjectId);
      if (s.isNull)
        r.fail(at, "The data subject no longer exists");
      else if (s.isDeleted)
        r.complete(at, "The personal data was already destroyed on " ~ isoDateText(s.deletedAt));
      else if (r.action == DeletionAction.block) {
        s.block(at);
        r.complete(at, "The data subject is blocked");
      } else if (s.legalHold) {
        s.block(at);
        r.reject(at, "The data subject is on legal hold; it is blocked instead");
      } else {
        auto e = new RuleBook(repos, t).evaluate(s, at);
        auto noObligation = e.phase == RetentionPhase.noRule || e.retention.duration == 0;
        if (e.phase == RetentionPhase.endOfRetention || noObligation) {
          s.destroy(at, r.action);
          r.complete(at, (r.action == DeletionAction.anonymize ? "The personal data is anonymized" : "The personal data is deleted")
            ~ (e.phase == RetentionPhase.endOfRetention ? "" : " (no retention obligation applies)"));
        } else {
          s.block(at);
          r.reject(at, e.endOfRetention > 0 ? "Retention obligation until " ~ isoDateText(e.endOfRetention)
              ~ " (" ~ e.governingLegalGroundName ~ "); the data subject is blocked instead"
              : "The business is not completed (no reference date); the data subject is blocked instead", e.endOfRetention);
        }
      }
      if (!s.isNull) {
        stampUpdated(s, actor, at);
        repos.dataSubjects.save(s);
      }
      stampUpdated(r, actor, at);
      repos.deletionRequests.save(r);
    });
    emit("deletionRequest." ~ cast(string) r.status, t, id.value, Json(["dataSubjectId": Json(r.dataSubjectId.value)]));
    return r;
  }

  DeletionRequest cancel(TenantId t, DeletionRequestId id, UserId actor) {
    auto r = get(t, id);
    r.cancel(now);
    stampUpdated(r, actor, now);
    repos.deletionRequests.save(r);
    emit("deletionRequest.cancelled", t, id.value);
    return r;
  }

  DeletionRequest get(TenantId t, DeletionRequestId id) {
    return required(repos.deletionRequests.findById(t, id), "Deletion request '" ~ id.value ~ "'");
  }

  DeletionRequest[] list(TenantId t) {
    return repos.deletionRequests.findAll(t);
  }

  void remove(TenantId t, DeletionRequestId id, UserId actor) {
    auto r = get(t, id);
    if (r.isPending)
      throw DataRetentionException.ruleViolation("Deletion request '" ~ id.value ~ "' is pending — cancel it first");
    repos.deletionRequests.removeById(t, id);
    emit("deletionRequest.deleted", t, id.value, Json(["by": Json(actor.value)]));
  }

  RunSummary processPending(TenantId t, UserId actor) {
    RunSummary summary;
    foreach (r; repos.deletionRequests.findAll(t)) {
      if (!r.isPending)
        continue;
      summary.started++;
      try {
        auto done = process(t, r.id, actor);
        if (done.status == DeletionRequestStatus.completed)
          summary.completed++;
        else if (done.status == DeletionRequestStatus.rejected)
          summary.rejected++;
        else
          summary.failed++;
      } catch (DataRetentionException e) {
        summary.failed++;
        r.fail(now, e.msg);
        repos.deletionRequests.save(r);
      }
    }
    return summary;
  }
}
