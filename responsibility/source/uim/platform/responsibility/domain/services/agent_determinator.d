/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.services.agent_determinator;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

/// AgentDeterminator is the core domain service that applies a responsibility
/// rule to a business-object context and returns a list of resolved agent IDs.
class AgentDeterminator {
    private TeamMemberRepository _memberRepo;
    private ResponsibilityDefinitionRepository _defRepo;

    this(TeamMemberRepository memberRepo,
         ResponsibilityDefinitionRepository defRepo) {
        _memberRepo = memberRepo;
        _defRepo    = defRepo;
    }

    /// Determine responsible agents for the given context and business object.
    /// Returns an array of user IDs. Empty means no agent was found.
    string[] determine(TenantId tenantId,
                       ResponsibilityRule rule,
                       string objectType,
                       string objectId) {
        final switch (rule.ruleType) {
            case RuleType.directAssignment:
                return resolveDirectAssignment(tenantId, rule);
            case RuleType.teamBased:
                return resolveTeamBased(tenantId, rule);
            case RuleType.businessRule:
                // In a real implementation this would evaluate rule.expression
                return resolveDirectAssignment(tenantId, rule);
            case RuleType.hierarchical:
                return resolveDirectAssignment(tenantId, rule);
        }
    }

    private string[] resolveDirectAssignment(TenantId tenantId, ResponsibilityRule rule) {
        if (rule.teamId.length == 0) return [];
        auto members = _memberRepo.findByTeam(tenantId, rule.teamId);
        string[] agents;
        foreach (m; members) {
            if (m.role == MemberRole.responsible || m.role == MemberRole.accountable)
                agents ~= m.userId;
        }
        return agents;
    }

    private string[] resolveTeamBased(TenantId tenantId, ResponsibilityRule rule) {
        return resolveDirectAssignment(tenantId, rule);
    }
}
