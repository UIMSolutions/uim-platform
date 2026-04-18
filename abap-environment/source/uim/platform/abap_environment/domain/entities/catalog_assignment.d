module uim.platform.abap_environment.domain.entities.catalog_assignment;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:

/// Catalog assignment attached to a role.
struct CatalogAssignment {
    CatalogAssignmentId id;
    string catalogName;

    Json toJson() const {
        return Json.emptyObject
            .set("id", id)
            .set("catalogName", catalogName);
    }
}
