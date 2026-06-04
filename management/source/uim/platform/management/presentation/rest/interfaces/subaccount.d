module uim.platform.management.presentation.rest.interfaces.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface ISubaccountApi {
    // GET /rest/v1/subaccounts
    @headerParam("tenantId", "X-Tenant-ID")
    Subaccount[] getSubaccounts(string tenantId);

    // GET /rest/v1/subaccounts/:id
    @headerParam("tenantId", "X-Tenant-ID")
    Subaccount getSubaccount(string tenantId, string id);
}