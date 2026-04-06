/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.data_context;

import uim.platform.situation_automation.domain.types;

struct DataContext {
    DataContextId id;
    SituationInstanceId instanceId;
    TenantId tenantId;
    string entityId;
    string entityTypeId;
    string[][] data;
    string sourceSystem;
    bool containsPersonalData;
    long capturedAt;
    long expiresAt;
}
