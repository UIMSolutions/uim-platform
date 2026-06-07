module uim.platform.management.presentation.rest.interfaces.label;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
interface ILabelApi {
    // GET /rest/v1/labels
    @headerParam("tenantId", "X-Tenant-ID")
    Label[] getLabels(string tenantId);

    // GET /rest/v1/labels/:id
    @headerParam("tenantId", "X-Tenant-ID")
    Label getLabel(string tenantId, string id);
}