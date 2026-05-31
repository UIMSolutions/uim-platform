module uim.platform.abap_environment.domain.entities.catalog_assignment;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Catalog assignment attached to a role.
struct CatalogAssignment {
    mixin TenantEntity!CatalogAssignmentId;
    string catalogName;

    Json toJson() const {
        return entityToJson()
            .set("catalogName", catalogName);
    }
}
