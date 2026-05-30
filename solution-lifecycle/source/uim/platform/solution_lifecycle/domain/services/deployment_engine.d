/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.services.deployment_engine;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

/// Result of a simulated deployment validation / processing step.
struct DeploymentResult {
    bool    success;
    string  operationId;
    string  message;
    int     estimatedSeconds;
}

/// Domain service encapsulating MTA deployment and validation logic.
/// In production this would call the CF MTA plugin API or BTP deployment API.
class DeploymentEngine {

    /// Validate an MTA archive's descriptor before deploying.
    /// Returns error message on failure, empty string on success.
    string validateArchive(string mtaId, string mtaVersion, string[] targetPlatforms) {
        if (mtaId.length == 0)      return "mtaId is required in the MTA descriptor";
        if (mtaVersion.length == 0) return "mtaVersion is required in the MTA descriptor";
        return "";
    }

    /// Simulate beginning an async deploy operation.
    DeploymentResult beginDeploy(string archiveId, string mtaId, string mtaVersion, TenantId tenantId) {
        
        import core.time : MonoTime;
        auto opId = "op-" ~ tenantId[0 .. (tenantId.length > 8 ? 8 : $)]
                  ~ "-" ~ MonoTime.currTime.ticks.to!string;
        return DeploymentResult(true, opId, "Deploy operation queued", 30);
    }

    /// Simulate beginning an async update operation.
    DeploymentResult beginUpdate(string archiveId, string existingMtaId, TenantId tenantId) {
        
        import core.time : MonoTime;
        auto opId = "op-upd-" ~ MonoTime.currTime.ticks.to!string;
        return DeploymentResult(true, opId, "Update operation queued", 20);
    }

    /// Simulate beginning an async delete operation.
    DeploymentResult beginDelete(string mtaId, TenantId tenantId) {
        
        import core.time : MonoTime;
        auto opId = "op-del-" ~ MonoTime.currTime.ticks.to!string;
        return DeploymentResult(true, opId, "Delete operation queued", 10);
    }

    /// Simulate beginning a subscribe operation.
    DeploymentResult beginSubscribe(string providerMtaId, string providerTenantId, string subscriberTenantId) {
        
        import core.time : MonoTime;
        auto opId = "op-sub-" ~ MonoTime.currTime.ticks.to!string;
        return DeploymentResult(true, opId, "Subscribe operation queued", 15);
    }

    /// Simulate beginning an unsubscribe operation.
    DeploymentResult beginUnsubscribe(string subscriptionId, TenantId tenantId) {
        
        import core.time : MonoTime;
        auto opId = "op-unsub-" ~ MonoTime.currTime.ticks.to!string;
        return DeploymentResult(true, opId, "Unsubscribe operation queued", 10);
    }

    /// Progress an operation one step forward (mock polling).
    /// Returns new status.
    OperationStatus advanceOperation(OperationStatus current, int currentPercent, out int newPercent) {
        if (current == OperationStatus.finished || current == OperationStatus.failed
                || current == OperationStatus.aborted) {
            newPercent = currentPercent;
            return current;
        }
        newPercent = currentPercent + 25;
        if (newPercent >= 100) {
            newPercent = 100;
            return OperationStatus.finished;
        }
        return OperationStatus.running;
    }
}
