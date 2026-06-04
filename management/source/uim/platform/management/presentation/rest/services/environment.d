module uim.platform.management.presentation.rest.services.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class EnvironmentApi : IEnvironmentApi {
    private ManageEnvironmentsUseCase usecase;

    this(ManageEnvironmentsUseCase usecase) {
        this.usecase = usecase;
    }

    override Environment[] getEnvironments(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override Environment getEnvironment(string tenantId, string id) {
        logInfo("Anfrage für Tenant-ID: %s, Environment-ID: %s", tenantId, id);

        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }

        return Environment.init;
    }
}