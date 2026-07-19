/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.entities.mta_operation;

import uim.platform.solution_lifecycle;
mixin(ShowModule!());

@safe:

/// An async operation record tracking a deploy / update / subscribe / delete lifecycle step.
class MtaOperation {
    mixin TenantEntity!(MtaOperationId);

    OperationType   operationType;
    OperationStatus operationStatus;
    string          mtaId;          /// The MTA application ID affected
    string          mtaVersion;
    string          archiveId;      /// Source archive (set for deploy/update)
    string          initiatedBy;    /// User who triggered the operation
    string          errorMessage;
    string          progressMessage;
    int             progressPercent; /// 0-100
    string[]        logLines;        /// Streaming log lines
    long            startedAt;
    long            finishedAt;

    Json toJson() {
        auto j = Json.emptyObject;
        j["id"]              = id.value;
        j["tenantId"]        = tenantId;
        j["operationType"]   = operationType.to!string;
        j["operationStatus"] = operationStatus.to!string;
        j["mtaId"]           = mtaId;
        j["mtaVersion"]      = mtaVersion;
        j["archiveId"]       = archiveId;
        j["initiatedBy"]     = initiatedBy;
        j["errorMessage"]    = errorMessage;
        j["progressMessage"] = progressMessage;
        j["progressPercent"] = progressPercent;
        j["startedAt"]       = startedAt;
        j["finishedAt"]      = finishedAt;
        auto logs = Json.emptyArray;
        foreach (line; logLines) logs ~= Json(line);
        j["logLines"] = logs;
        j["createdAt"] = createdAt;
        j["updatedAt"] = updatedAt;
        return j;
    }

    bool isNull() { return id.value.length == 0; }
}
