module uim.platform.architecture.presentation.ui5.helpers.tenant;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

string tenant(scope HTTPServerRequest req) {
    return req.query.get("tenantId", "default");
}
