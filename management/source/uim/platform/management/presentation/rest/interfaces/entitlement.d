module uim.platform.management.presentation.rest.interfaces.entitlement;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IEntitlementApi {
    // GET /rest/v1/entitlements
    Entitlement[] getEntitlements();
}
