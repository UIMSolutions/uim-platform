/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// End-of-purpose check ("Delete Data Subject Information" run) and the
/// retention simulation.
///
/// For every data subject that is not destroyed:
///   past the end of purpose and active        → blocked
///   past the end of retention, no legal hold  → marked for deletion
/// The destruction itself is done by an archiving job (operation destruct)
/// or by a deletion request.
module uim.platform.data_retention.application.usecases.checks;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class RetentionChecksUseCase : DrInteractor, IRetentionChecks {
  this(DrRepositories repos, IClock clock, IDrEventPublisher events, IDrUnitOfWork unitOfWork, DrPolicy policy) {
    super(repos, clock, events, unitOfWork, policy);
  }

  EndOfPurposeCheckResult checkEndOfPurpose(EndOfPurposeCheckRequest r) {
    EndOfPurposeCheckResult result;
    result.simulated = r.simulate;
    result.applicationGroupId = r.applicationGroupId.value;
    auto at = now;
    result.checkedAt = at;
    DataSubject[] subjects;
    if (r.applicationGroupId.isNull)
      subjects = repos.dataSubjects.findAll(r.tenantId);
    else {
      applicationGroupOf(r.tenantId, r.applicationGroupId.value);
      subjects = repos.dataSubjects.findByReference(r.tenantId, "applicationGroupId", r.applicationGroupId.value);
    }
    auto book = new RuleBook(repos, r.tenantId);

    batch(() {
      foreach (s; subjects) {
        if (s.isDeleted) {
          result.alreadyDeleted++;
          continue;
        }
        result.checked++;
        auto e = book.evaluate(s, at);
        final switch (e.phase) {
        case RetentionPhase.noRule:
          result.noRule++;
          break;
        case RetentionPhase.withinResidence:
          result.withinResidence++;
          break;
        case RetentionPhase.withinRetention:
          result.withinRetention++;
          break;
        case RetentionPhase.endOfRetention:
          result.endOfRetention++;
          break;
        }
        bool changed, marked;
        if (e.phase == RetentionPhase.endOfRetention && s.lifecycleStatus != LifecycleStatus.markedForDeletion) {
          if (s.legalHold)
            result.legalHolds++;
          else {
            marked = true;
            result.markedForDeletion++;
            result.markedSubjects ~= s.id.value;
            if (!r.simulate) {
              s.markForDeletion(at);
              changed = true;
            }
          }
        }
        if (!marked && e.dueForBlocking(s.lifecycleStatus)) {
          result.blocked++;
          result.blockedSubjects ~= s.id.value;
          if (!r.simulate) {
            s.block(at);
            changed = true;
          }
        }
        if (changed) {
          stampUpdated(s, r.actor, at);
          repos.dataSubjects.save(s);
          emit("dataSubject." ~ (s.lifecycleStatus == LifecycleStatus.markedForDeletion ? "markedForDeletion" : "blocked"),
            r.tenantId, s.id.value);
        }
      }
    });
    emit("endOfPurpose.checked", r.tenantId, r.applicationGroupId.value, Json([
        "checked": Json(result.checked), "blocked": Json(result.blocked), "markedForDeletion": Json(result.markedForDeletion),
        "simulated": Json(r.simulate)
      ]));
    return result;
  }

  RetentionEvaluation simulate(SimulationRequest r) {
    auto p = businessPurposeOf(r.tenantId, r.businessPurposeId.value);
    if (!r.legalGroundId.isNull) {
      auto g = legalGroundOf(r.tenantId, r.legalGroundId.value);
      if (g.businessPurposeId != p.id)
        throw DataRetentionException.invalid("Legal ground '" ~ g.id.value ~ "' does not belong to business purpose '"
            ~ p.id.value ~ "'");
    }
    if (r.referenceDate <= 0)
      throw DataRetentionException.invalid("A reference date is required");
    // a simulation also works for purposes that are not active yet
    auto book = new RuleBook(repos, r.tenantId);
    auto e = evaluateRetention(r.referenceDate, book.rulesOf(p.id).filter!(g => r.legalGroundId.isNull
        || g.legalGroundId == r.legalGroundId).array, now);
    if (!p.appliesRules)
      e.reason ~= " — note: the business purpose is inactive, its rules are not applied yet";
    return e;
  }
}
