/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.types;

import uim.platform.print;

mixin(ShowModule!());

@safe:

struct PrintQueueId {
    mixin(IdTemplate);
}

struct PrintTaskId {
    mixin(IdTemplate);
}

struct PrinterId {
    mixin(IdTemplate);
}

struct PrintDocumentId {
    mixin(IdTemplate);
}

struct PrintClientId {
    mixin(IdTemplate);
}
