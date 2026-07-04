module uim.platform.management.presentation.rest.services.overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class OverviewApi : IOverviewApi {
    private GetAccountOverviewUseCase usecase;
// 
    this(GetAccountOverviewUseCase usecase) {
        this.usecase = usecase;
    }

    override Json getOverview(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return Json(null);
    }
}