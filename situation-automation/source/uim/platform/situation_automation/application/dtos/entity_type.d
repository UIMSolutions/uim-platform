module uim.platform.situation_automation.application.dtos.entity_type;
import uim.platform.situation_automation;

// mixin(ShowModule!());

@safe:
struct CreateEntityTypeRequest {
    TenantId tenantId;
    EntityTypeId entityTypeId;
    string name;
    string description;
    string category;
    string sourceSystem;
    UserId createdBy;
}

struct UpdateEntityTypeRequest {
    TenantId tenantId;
    EntityTypeId entityTypeId;
    string name;
    string description;
    string category;
    UserId updatedBy;
}