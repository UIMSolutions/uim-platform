/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.situation_automation.domain.entities.data_context;

// import uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
struct DataContext {
    mixin TenantEntity!(DataContextId);

    SituationInstanceId instanceId;
    string entityId;
    string entityTypeId;
    string[][] data;
    string sourceSystem;
    bool containsPersonalData;
    long capturedAt;
    long expiresAt;

    Json toJson() const {
        auto j = entityToJson
            .set("instanceId", instanceId.value)
            .set("entityId", entityId)
            .set("entityTypeId", entityTypeId)
            .set("data", data.map!(row => row.array).array)
            .set("sourceSystem", sourceSystem)
            .set("containsPersonalData", containsPersonalData)
            .set("capturedAt", capturedAt)
            .set("expiresAt", expiresAt);

        return j;
    }
}
