/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.domain.types;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

struct ResponsibilityRuleId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct TeamCategoryId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct TeamTypeId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct TeamId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct TeamMemberId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct MemberFunctionId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct ResponsibilityContextId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct ResponsibilityDefinitionId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}

struct DeterminationLogId {
    string value;
    this(string v) { value = v; }
    mixin IdTemplate;
}
