/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.build_apps.domain.types;

import uim.platform.build_apps;

mixin(ShowModule!());

@safe:

struct PageId {
    mixin(IdTemplate);
}

struct UIComponentId {
    mixin(IdTemplate);
}

struct DataEntityId {
    mixin(IdTemplate);
}

struct DataConnectionId {
    mixin(IdTemplate);
}

struct LogicFlowId {
    mixin(IdTemplate);
}

struct AppBuildId {
    mixin(IdTemplate);
}

struct ProjectMemberId {
    mixin(IdTemplate);
}
