/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.determine_agents;

import uim.platform.responsibility;


mixin(ShowModule!());

@safe:

/// Use case that drives agent determination for a given business-object context.
/// Records a DeterminationLog regardless of outcome.
class DetermineAgentsUseCase {
    private ResponsibilityContextRepository  _contextRepo;
    private ResponsibilityRuleRepository     _ruleRepo;
    private DeterminationLogRepository       _logRepo;
    private AgentDeterminator                _determinator;

    this(ResponsibilityContextRepository contextRepo,
         ResponsibilityRuleRepository ruleRepo,
         DeterminationLogRepository logRepo,
         AgentDeterminator determinator) {
        _contextRepo  = contextRepo;
        _ruleRepo     = ruleRepo;
        _logRepo      = logRepo;
        _determinator = determinator;
    }

    DetermineAgentsResult determine(DetermineAgentsRequest req) {
        import std.uuid : randomUUID;
        immutable startMs = MonoTime.currTime.ticks / 1_000_000;

        // Resolve context
        auto ctx = _contextRepo.findById(req.tenantId, ResponsibilityContextId(req.contextId));
        if (ctx.isNull)
            return writeLog(req, [], DeterminationStatus.error,
                            "Context not found: " ~ req.contextId, startMs);

        // Find active rules for this context
        auto rules = _ruleRepo.findByContext(req.tenantId, req.contextId);
        if (rules.length == 0)
            return writeLog(req, [], DeterminationStatus.noAgentFound,
                            "No rules for context " ~ req.contextId, startMs);

        // Use first (highest priority) matching rule
        string[] agents = _determinator.determine(
            req.tenantId, rules[0], req.objectType, req.objectId);

        immutable status = agents.length > 0
            ? DeterminationStatus.success
            : DeterminationStatus.noAgentFound;

        return writeLog(req, agents, status, agents.length > 0 ? "" : "No agents resolved", startMs,
                        rules[0].id.value);
    }

    private DetermineAgentsResult writeLog(DetermineAgentsRequest req,
                                           string[] agents,
                                           DeterminationStatus status,
                                           string errorMsg,
                                           long startMs,
                                           string ruleId = "") {
        import std.uuid : randomUUID;
        
        immutable elapsed = MonoTime.currTime.ticks / 1_000_000 - startMs;

        auto log = DeterminationLog(req.tenantId, DeterminationLogId(createId), UserId("system"));
        log.contextId       = req.contextId;
        log.ruleId          = ruleId;
        log.objectType      = req.objectType;
        log.objectId        = req.objectId;
        log.status          = status;
        log.resolvedAgents  = agents;
        log.errorMessage    = errorMsg;
        log.callerApp       = req.callerApp;
        log.executionTimeMs = elapsed;

        _logRepo.save(log);

        return DetermineAgentsResult(
            status == DeterminationStatus.success,
            agents,
            log.id.value,
            errorMsg
        );
    }
}
