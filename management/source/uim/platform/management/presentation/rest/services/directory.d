module uim.platform.management.presentation.rest.services.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:
class DirectoryApi : IDirectoryApi {
    private ManageDirectoriesUseCase usecase;

    this(ManageDirectoriesUseCase usecase) {
        this.usecase = usecase;
    }

    override Directory[] getDirectories(string tenantId) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s", tenantId);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant...
        return null;
    }

    override Directory getDirectory(string tenantId, string id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, Directory-ID: %s", tenantId, id);
        
        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }
        
        // Deine Logik gefiltert nach Tenant und ID...
        return Directory.init;
    }
}
