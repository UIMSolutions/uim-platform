/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.solution_lifecycle.domain.types;

import uim.platform.solution_lifecycle;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// Domain ID value types
// ---------------------------------------------------------------------------

struct MtaArchiveId {
    mixin IdTemplate;


    this(string value) {
        this.value = value;
    }

    string value;
}

struct MtaId {
    mixin IdTemplate;
    this(string value) {
        this.value = value;
    }

    string value;
}

struct MtaOperationId {
    mixin IdTemplate;
    this(string value) {
        this.value = value;
    }

    string value;
}

struct MtaSubscriptionId {
    mixin IdTemplate;
    this(string value) {
        this.value = value;
    }

    string value;
}
