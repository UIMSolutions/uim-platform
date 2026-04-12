module uim.platform.abap_enviroment.domain.entities.catalog_assignment;

import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:

/// Catalog assignment attached to a role.
struct CatalogAssignment {
    string catalogId;
    string catalogName;

    Json toJson() const {
        return Json.emptyObject
            .set("catalogId", catalogId)
            .set("catalogName", catalogName);
    }
}
