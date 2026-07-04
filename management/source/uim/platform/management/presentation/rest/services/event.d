module uim.platform.management.presentation.rest.services.event;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class EnvironmentEventApi : IEnvironmentEventApi {
    private QueryEnvironmentEventsUseCase usecase;

    this(QueryEnvironmentEventsUseCase usecase) {
        this.usecase = usecase;
    }

    // override EnvironmentEvent[] getEvents(string tenantId) {
    //     // Hier hast du Zugriff auf die tenantId
    //     logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
    //     if (tenantId.length == 0) {
    //         throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
    //     }
        
    //     // Deine Logik gefiltert nach Tenant...
    //     return null;
    // }
}