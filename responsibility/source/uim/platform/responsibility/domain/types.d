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
    mixin DomainId;
}

struct TeamCategoryId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct TeamTypeId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct TeamId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct TeamMemberId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct MemberFunctionId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct ResponsibilityContextId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct ResponsibilityDefinitionId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}

struct DeterminationLogId {
    string value;
    this(string v) { value = v; }
    mixin DomainId;
}
