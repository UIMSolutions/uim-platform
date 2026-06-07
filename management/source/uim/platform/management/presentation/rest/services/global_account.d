module uim.platform.management.presentation.rest.services.global_account;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
class GlobalAccountApi : IGlobalAccountApi {
    private ManageGlobalAccountsUseCase usecase;

    this(ManageGlobalAccountsUseCase usecase) {
        this.usecase = usecase;
    }

    override GlobalAccount[] getGlobalAccounts(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override GlobalAccount getGlobalAccount(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, GlobalAccount-ID: %s", tenantId, id);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return GlobalAccount.init;
    }
}