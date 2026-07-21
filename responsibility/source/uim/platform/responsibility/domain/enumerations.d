/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.enumerations;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

enum RuleType {
    directAssignment,
    businessRule,
    teamBased,
    hierarchical
}
RuleType toRuleType(string type) {
    mixin(EnumSwitch("RuleType", "directAssignment"));
}
RuleType[] toRuleTypes(string[] types) {
    return types.map!(t => toRuleType(t)).array;
}
string toString(RuleType type) {
    return type.to!string;
}
string[] toStrings(RuleType[] types) {
    return types.map!(t => t.to!string).array;
}
///
unittest {
    mixin(ShowTest!("RuleType"));

    assert("directAssignment".toRuleType == RuleType.directAssignment);
    assert("businessRule".toRuleType == RuleType.businessRule);
    assert("teamBased".toRuleType == RuleType.teamBased);
    assert("hierarchical".toRuleType == RuleType.hierarchical);

    assert("".toRuleType == RuleType.hierarchical);
    assert("unknown".toRuleType == RuleType.hierarchical);

    assert(toString(RuleType.directAssignment) == "directAssignment");
    assert(toString(RuleType.businessRule) == "businessRule");
    assert(toString(RuleType.teamBased) == "teamBased");
    assert(toString(RuleType.hierarchical) == "hierarchical");

    assert(toStrings([RuleType.directAssignment, RuleType.businessRule]) == ["directAssignment", "businessRule"]);
    assert(toRuleTypes(["directAssignment", "businessRule"]) == [RuleType.directAssignment, RuleType.businessRule]);
}

enum RuleStatus {
    active,
    inactive,
    draft
}
RuleStatus toRuleStatus(string status) {
    mixin(EnumSwitch("RuleStatus", "active"));
}
RuleStatus[] toRuleStatuses(string[] statuses) {
    return statuses.map!(s => toRuleStatus(s)).array;
}
string toString(RuleStatus status) {
    return status.to!string;
}
string[] toStrings(RuleStatus[] statuses) {
    return statuses.map!(s => s.to!string).array;
}
///
unittest {
    mixin(ShowTest!("RuleStatus"));

    assert("active".toRuleStatus == RuleStatus.active);
    assert("inactive".toRuleStatus == RuleStatus.inactive);
    assert("draft".toRuleStatus == RuleStatus.draft);

    assert("".toRuleStatus == RuleStatus.active);
    assert("unknown".toRuleStatus == RuleStatus.active);

    assert(toString(RuleStatus.active) == "active");
    assert(toString(RuleStatus.inactive) == "inactive");
    assert(toString(RuleStatus.draft) == "draft");

    assert(toStrings([RuleStatus.active, RuleStatus.inactive]) == ["active", "inactive"]);
    assert(toRuleStatuses(["active", "inactive"]) == [RuleStatus.active, RuleStatus.inactive]);
}

enum TeamStatus {
    active,
    inactive,
    archived
}
TeamStatus toTeamStatus(string status) {
    mixin(EnumSwitch("TeamStatus", "active"));
}
TeamStatus[] toTeamStatuses(string[] statuses) {
    return statuses.map!(s => toTeamStatus(s)).array;
}
string toString(TeamStatus status) {
    return status.to!string;
}
string[] toStrings(TeamStatus[] statuses) {
    return statuses.map!(s => s.to!string).array;
}
///
unittest {
    mixin(ShowTest!("TeamStatus"));

    assert("active".toTeamStatus == TeamStatus.active);
    assert("inactive".toTeamStatus == TeamStatus.inactive);
    assert("archived".toTeamStatus == TeamStatus.archived);

    assert("".toTeamStatus == TeamStatus.active);
    assert("unknown".toTeamStatus == TeamStatus.active);

    assert(toString(TeamStatus.active) == "active");
    assert(toString(TeamStatus.inactive) == "inactive");
    assert(toString(TeamStatus.archived) == "archived");

    assert(toStrings([TeamStatus.active, TeamStatus.inactive]) == ["active", "inactive"]);
    assert(toTeamStatuses(["active", "inactive"]) == [TeamStatus.active, TeamStatus.inactive]);
} 

enum MemberRole {
    responsible,
    accountable,
    consulted,
    informed
}
MemberRole toMemberRole(string role) {
    mixin(EnumSwitch("MemberRole", "responsible"));
}
MemberRole[] toMemberRoles(string[] roles) {
    return roles.map!(r => toMemberRole(r)).array;
}
string toString(MemberRole role) {
    return role.to!string;
}
string[] toStrings(MemberRole[] roles) {
    return roles.map!(r => r.to!string).array;
}
///
unittest {
    mixin(ShowTest!("MemberRole"));

    assert("responsible".toMemberRole == MemberRole.responsible);
    assert("accountable".toMemberRole == MemberRole.accountable);
    assert("consulted".toMemberRole == MemberRole.consulted);
    assert("informed".toMemberRole == MemberRole.informed);

    assert("".toMemberRole == MemberRole.responsible);
    assert("unknown".toMemberRole == MemberRole.responsible);

    assert(toString(MemberRole.responsible) == "responsible");
    assert(toString(MemberRole.accountable) == "accountable");
    assert(toString(MemberRole.consulted) == "consulted");
    assert(toString(MemberRole.informed) == "informed");

    assert(toStrings([MemberRole.responsible, MemberRole.accountable]) == ["responsible", "accountable"]);
    assert(toMemberRoles(["responsible", "accountable"]) == [MemberRole.responsible, MemberRole.accountable]);
}

enum FunctionStatus {
    active,
    inactive
}
FunctionStatus toFunctionStatus(string status) {
    mixin(EnumSwitch("FunctionStatus", "active"));
}
FunctionStatus[] toFunctionStatuses(string[] statuses) {
    return statuses.map!(s => toFunctionStatus(s)).array;
}
string toString(FunctionStatus status) {
    return status.to!string;
}
string[] toStrings(FunctionStatus[] statuses) {
    return statuses.map!(s => s.to!string).array;
}
///
unittest {
    mixin(ShowTest!("FunctionStatus")); 

    assert("active".toFunctionStatus == FunctionStatus.active);
    assert("inactive".toFunctionStatus == FunctionStatus.inactive);

    assert("".toFunctionStatus == FunctionStatus.active);
    assert("unknown".toFunctionStatus == FunctionStatus.active);

    assert(toString(FunctionStatus.active) == "active");
    assert(toString(FunctionStatus.inactive) == "inactive");

    assert(toStrings([FunctionStatus.active, FunctionStatus.inactive]) == ["active", "inactive"]);
    assert(toFunctionStatuses(["active", "inactive"]) == [FunctionStatus.active, FunctionStatus.inactive]);
}

enum ContextStatus {
    active,
    inactive
}
ContextStatus toContextStatus(string status) {
    mixin(EnumSwitch("ContextStatus", "active"));
}
ContextStatus[] toContextStatuses(string[] statuses) {
    return statuses.map!(s => toContextStatus(s)).array;
}
string toString(ContextStatus status) {
    return status.to!string;
}
string[] toStrings(ContextStatus[] statuses) {
    return statuses.map!(s => s.to!string).array;
}
///
unittest {
    mixin(ShowTest!("ContextStatus"));

    assert("active".toContextStatus == ContextStatus.active);
    assert("inactive".toContextStatus == ContextStatus.inactive);

    

enum DeterminationStatus {
    success,
    noAgentFound,
    error
}

enum AssignmentScope {
    global_,
    regional,
    site
}

enum DefinitionStatus {
    active,
    inactive
}
