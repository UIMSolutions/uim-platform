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
    mixin(IdTemplate);
}

struct TeamCategoryId {
    mixin(IdTemplate);
}

struct TeamTypeId {
    mixin(IdTemplate);
}

struct TeamId {
    mixin(IdTemplate);
}

struct TeamMemberId {
    mixin(IdTemplate);
}

struct MemberFunctionId {
    mixin(IdTemplate);
}

struct ResponsibilityContextId {
    mixin(IdTemplate);
}

struct ResponsibilityDefinitionId {
    mixin(IdTemplate);
}

struct DeterminationLogId {
    mixin(IdTemplate);
}
