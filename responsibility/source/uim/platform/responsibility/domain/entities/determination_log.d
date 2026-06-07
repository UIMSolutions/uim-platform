/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.entities.determination_log;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

/// DeterminationLog records a single agent-determination request — what context
/// was used, what input object was provided, and which agents were resolved.
struct DeterminationLog {
    mixin TenantEntity!(DeterminationLogId);

    string contextId;           // linked ResponsibilityContextId value
    string ruleId;              // linked ResponsibilityRuleId value (resolved rule)
    string objectType;          // business object type
    string objectId;            // business object instance ID
    DeterminationStatus status  = DeterminationStatus.success;
    string[] resolvedAgents;    // user IDs of determined agents
    string errorMessage;        // filled when status == error
    string callerApp;           // application that triggered determination
    long executionTimeMs        = 0;

    Json toJson() const {
        import std.algorithm : map;
        import std.array : array;
        auto agents = resolvedAgents.map!(a => Json(a)).array;
        return entityToJson
            .set("contextId",       contextId)
            .set("ruleId",          ruleId)
            .set("objectType",      objectType)
            .set("objectId",        objectId)
            .set("status",          status.to!string)
            .set("resolvedAgents",  agents.toJson)
            .set("errorMessage",    errorMessage)
            .set("callerApp",       callerApp)
            .set("executionTimeMs", executionTimeMs);
    }
}
