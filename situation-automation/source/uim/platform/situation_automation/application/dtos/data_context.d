module uim.platform.situation_automation.application.dtos.data_context;

import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
struct CreateDataContextRequest {
    TenantId tenantId;
    SituationInstanceId situationInstanceId;
    DataContextId dataContextId;
    string entityId;
    EntityTypeId entityTypeId;
    string[][] data;
    string sourceSystem;
    bool containsPersonalData;
    long expiresAt;
}

struct DeleteDataContextRequest {
    TenantId tenantId;
    DataContextId dataContextId;
}