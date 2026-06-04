module uim.platform.management.presentation.rest.services.subaccount;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class SubaccountApi : ISubaccountApi {
    private ManageSubaccountsUseCase usecase;

    this(ManageSubaccountsUseCase usecase) {
        this.usecase = usecase;
    }

    override Subaccount[] getSubaccounts(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override Subaccount getSubaccount(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, Subaccount-ID: %s", tenantId, id);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return Subaccount.init;
    }
}