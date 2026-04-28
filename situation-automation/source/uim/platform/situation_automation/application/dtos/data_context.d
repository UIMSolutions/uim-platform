module uim.platform.situation_automation.application.dtos.data_context;

struct CreateDataContextRequest {
    TenantId tenantId;
    string instanceId;
    string id;
    string entityId;
    string entityTypeId;
    string[][] data;
    string sourceSystem;
    bool containsPersonalData;
    long expiresAt;
}

struct DeleteDataContextRequest {
    TenantId tenantId;
    string id;
}