module uim.platform.management.presentation.rest.services.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class EntitlementApi : IEntitlementApi {
    private ManageEntitlementsUseCase usecase;

    this(ManageEntitlementsUseCase usecase) {
        this.usecase = usecase;
    }

    override Entitlement[] getEntitlements(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
 
    }
}