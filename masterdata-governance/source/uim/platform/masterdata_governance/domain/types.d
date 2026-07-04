/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.types;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:
// --- ID Aliases ---
struct BusinessPartnerId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ChangeRequestId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DataQualityRuleId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct DataQualityScoreId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}

struct ReplicationId {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin IdTemplate;
}
