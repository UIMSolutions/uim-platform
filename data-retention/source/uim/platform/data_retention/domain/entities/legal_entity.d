module uim.platform.data_retention.domain.entities.legal_entity;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct LegalEntity {
    mixin TenantEntity!(LegalEntityId);

    string name;
    string description;
    string country;
    string region;
    bool isActive = true;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("country", country)
            .set("region", region)
            .set("isActive", isActive);
    }
}
