module uim.platform.management.presentation.rest.interfaces.global_account;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
interface IGlobalAccountApi {
    // GET /rest/v1/global-accounts
    @headerParam("tenantId", "X-Tenant-ID")
    GlobalAccount[] getGlobalAccounts(string tenantId);

    // GET /rest/v1/global-accounts/:id
    @headerParam("tenantId", "X-Tenant-ID")
    GlobalAccount getGlobalAccount(string tenantId, string id);
}