/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.application.usecases.manage.mta_operations;

import uim.platform.solution_lifecycle;

// mixin(ShowModule!());

@safe:

class ManageMtaOperationsUseCase {
    private MtaOperationRepository repo;
    private DeploymentEngine       engine;

    this(MtaOperationRepository repo, DeploymentEngine engine) {
        this.repo   = repo;
        this.engine = engine;
    }

    MtaOperation[] listOperations(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    MtaOperation getOperation(TenantId tenantId, MtaOperationId id) {
        auto ops = repo.findByTenant(tenantId);
        foreach (op; ops)
            if (op.id.value == id.value) return op;
        return new MtaOperation();
    }

    /// Poll/advance an operation one step forward (mock simulation).
    CommandResult pollOperation(TenantId tenantId, MtaOperationId id) {
        import core.time : MonoTime;

        auto op = getOperation(tenantId, id);
        if (op is null || op.isNull) return CommandResult(false, "", "Operation not found");
        if (op.operationStatus == OperationStatus.finished
                || op.operationStatus == OperationStatus.failed
                || op.operationStatus == OperationStatus.aborted)
            return CommandResult(true, id.value, "");

        int newPct;
        auto newStatus = engine.advanceOperation(op.operationStatus, op.progressPercent, newPct);
        op.operationStatus = newStatus;
        op.progressPercent = newPct;
        op.progressMessage = newStatus == OperationStatus.finished ? "Operation completed" : "In progress";
        if (newStatus == OperationStatus.finished)
            op.finishedAt = MonoTime.currTime.ticks;
        op.updatedAt = MonoTime.currTime.ticks;
        repo.update(op);
        return CommandResult(true, id.value, "");
    }

    /// Abort a running operation.
    CommandResult abortOperation(AbortOperationRequest r) {
        import core.time : MonoTime;

        auto op = getOperation(r.tenantId, MtaOperationId(r.operationId));
        if (op is null || op.isNull) return CommandResult(false, "", "Operation not found");
        if (op.operationStatus == OperationStatus.finished
                || op.operationStatus == OperationStatus.aborted)
            return CommandResult(false, "", "Operation is already " ~ op.operationStatus.to!string);

        op.operationStatus = OperationStatus.aborted;
        op.progressMessage = "Aborted by " ~ r.abortedBy;
        op.finishedAt      = MonoTime.currTime.ticks;
        op.updatedAt       = op.finishedAt;
        repo.update(op);
        return CommandResult(true, r.operationId, "");
    }

    /// Retrieve streaming log lines for an operation.
    string[] getOperationLogs(TenantId tenantId, MtaOperationId id) {
        auto op = getOperation(tenantId, id);
        if (op is null || op.isNull) return [];
        return op.logLines;
    }
}
