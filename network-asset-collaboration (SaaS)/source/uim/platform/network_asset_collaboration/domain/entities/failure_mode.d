/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.entities.failure_mode;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

struct FailureMode {
    FailureModeId id;
    TenantId tenantId;
    string modelId;
    string name;
    string description;
    FailureSeverity severity = FailureSeverity.minor;
    string cause;
    string effect;
    string detection;
    string mitigation;
    string riskPriorityNumber;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
