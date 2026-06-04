module uim.platform.management.presentation.rest.services.label;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class LabelApi : ILabelApi {
    private ManageLabelsUseCase usecase;

    this(ManageLabelsUseCase usecase) {
        this.usecase = usecase;
    }

    override Label[] getLabels(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override Label getLabel(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, Label-ID: %s", tenantId, id);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return Label.init;
    }
}