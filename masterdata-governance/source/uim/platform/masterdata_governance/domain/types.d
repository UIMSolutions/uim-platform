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
    mixin(IdTemplate);
}

struct ChangeRequestId {
    mixin(IdTemplate);
}

struct DataQualityRuleId {
    mixin(IdTemplate);
}

struct DataQualityScoreId {
    mixin(IdTemplate);
}

struct ReplicationId {
    mixin(IdTemplate);
}
