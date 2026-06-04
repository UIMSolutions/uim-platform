module uim.platform.management.presentation.rest.interfaces.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface ISubaccountApi {
    // GET /rest/v1/subaccounts
    Subaccount[] getSubaccounts();

    // GET /rest/v1/subaccounts/:id
    Subaccount getSubaccount(string id);
}