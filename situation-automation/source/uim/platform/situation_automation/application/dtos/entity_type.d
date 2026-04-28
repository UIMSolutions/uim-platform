module uim.platform.situation_automation.application.dtos.entity_type;

struct CreateEntityTypeRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    string sourceSystem;
    UserId createdBy;
}

struct UpdateEntityTypeRequest {
    TenantId tenantId;
    string id;
    string name;
    string description;
    string category;
    UserId updatedBy;
}