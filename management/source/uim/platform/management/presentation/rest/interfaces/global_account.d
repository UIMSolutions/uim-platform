module uim.platform.management.presentation.rest.interfaces.global_account;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IGlobalAccountApi {
    // GET /rest/v1/global-accounts
    GlobalAccount[] getGlobalAccounts();

    // GET /rest/v1/global-accounts/:id
    GlobalAccount getGlobalAccount(string id);
}