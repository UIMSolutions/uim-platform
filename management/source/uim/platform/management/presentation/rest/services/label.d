module uim.platform.management.presentation.rest.services.label;

import uim.platform.management;

// mixin(ShowModule!());

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
///
unittest {
    auto repo = new MemoryLabelRepository();
    auto usecase = new ManageLabelsUseCase(repo);
    auto api = new LabelApi(usecase);
    
    string tenantId = "tenant-rest";
    
    // Test GET /rest/v1/labels
    auto labels = api.getLabels(tenantId);
    assert(labels is null); // Da wir noch keine Labels erstellt haben
    
    // Test GET /rest/v1/labels/:id
    auto label = api.getLabel(tenantId, "label-1");
    assert(label == Label.init); // Da wir noch kein Label mit id "label-1" erstellt haben
}