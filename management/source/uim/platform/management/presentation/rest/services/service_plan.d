module uim.platform.management.presentation.rest.services.service_plan;

import uim.platform.management;

// mixin(ShowModule!());

@safe:
class ServicePlanApi : IServicePlanApi {
    private ManageServicePlansUseCase usecase;

    this(ManageServicePlansUseCase usecase) {
        this.usecase = usecase;
    }

    override ServicePlan[] getServicePlans(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override ServicePlan getServicePlan(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return ServicePlan.init;
    }
}