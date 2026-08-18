/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.application.usecases.manage.composition_runs;

import uim.platform.datasphere_composer;

mixin(ShowModule!());

@safe:
class ManageCompositionRunsUseCase {
  protected ICompositionRunRepository repo;

  this(ICompositionRunRepository repo) { this.repo = repo; }

  UsecaseResult start(StartCompositionRunRequest r) {
    CompositionRun run;
    run.id = CompositionRunId(r.id.length > 0 ? r.id : currentTimestamp());
    run.tenantId = TenantId(r.tenantId);
    run.name = r.name.length > 0 ? r.name : "Run-" ~ run.id.value;
    run.status = CompositionRunStatus.pending;
    run.triggeredBy = r.triggeredBy.length > 0 ? r.triggeredBy : "SYSTEM";
    run.dataProductIds = r.dataProductIds;
    run.startedAt = currentTimestamp().length > 0 ? 0 : 0; // placeholder
    initEntity(run);

    repo.save(run);
    return UsecaseResult(true, run.id.value, null);
  }

  CompositionRun[] list(TenantId tenantId) {
    return repo.findByTenant(TenantId(tenantId));
  }

  CompositionRun[] listByStatus(TenantId tenantId, string status) {
    try {
      
      return repo.findByStatus(TenantId(tenantId), status.to!CompositionRunStatus);
    } catch (Exception) {
      return [];
    }
  }

  CompositionRun getById(TenantId tenantId, string id) {
    return repo.findById(TenantId(tenantId), CompositionRunId(id));
  }

  UsecaseResult performAction(CompositionRunActionRequest r) {
    auto run = repo.findById(TenantId(r.tenantId), CompositionRunId(r.id));
    if (run.isNull) return UsecaseResult(false, r.id, "Composition run not found");

    if (r.action == "cancel") {
      if (run.status != CompositionRunStatus.running &&
          run.status != CompositionRunStatus.pending) {
        return UsecaseResult(false, r.id, "Only running or pending runs can be cancelled");
      }
      run.status = CompositionRunStatus.cancelled;
      repo.update(run);
      return UsecaseResult(true, r.id, null);
    }

    return UsecaseResult(false, r.id, "Unknown action: " ~ r.action);
  }

  UsecaseResult remove(TenantId tenantId, string id) {
    auto run = repo.findById(TenantId(tenantId), CompositionRunId(id));
    if (run.isNull) return UsecaseResult(false, id, "Composition run not found");
    repo.remove(TenantId(tenantId), CompositionRunId(id));
    return UsecaseResult(true, id, null);
  }
}
