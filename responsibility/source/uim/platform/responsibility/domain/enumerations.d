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

enum RuleStatus {
    active,
    inactive,
    draft
}

enum TeamStatus {
    active,
    inactive,
    archived
}

enum MemberRole {
    responsible,
    accountable,
    consulted,
    informed
}

enum FunctionStatus {
    active,
    inactive
}

enum ContextStatus {
    active,
    inactive
}

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
