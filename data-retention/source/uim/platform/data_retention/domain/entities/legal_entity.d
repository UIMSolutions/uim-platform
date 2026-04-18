module uim.platform.data_retention.domain.entities.legal_entity;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct LegalEntity {
    LegalEntityId id;
    TenantId tenantId;
    string name;
    string description;
    string country;
    string region;
    bool isActive = true;
    string createdBy;
    long createdAt;
    long updatedAt;
}
