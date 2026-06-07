module uim.platform.management.presentation.rest.services.directory;

import uim.platform.management;

// mixin(ShowModule!());

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

        auto gaId = GlobalAccountId(`req.params.get("globalAccountId")`);
        auto parentId = DirectoryId(`req.params.get("parentDirectoryId")`);

        Directory[] items;
        if (!parentId.isEmpty)
            items = usecase.listDirectories(TenantId(tenantId), parentId);
        else if (!gaId.isEmpty)
            items = usecase.listDirectories(TenantId(tenantId), gaId);

        // Deine Logik gefiltert nach Tenant...
        return items;
    }

    override Directory getDirectory(string tenantId, string _id) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, Directory-ID: %s", tenantId, _id);

        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }

        // Deine Logik gefiltert nach Tenant und ID...
        auto result = usecase.getDirectory(TenantId(tenantId), DirectoryId(_id));
        if (result.isNull) {
            throw new HTTPStatusException(HTTPStatus.notFound, "Directory not found");
        }
        return result;
    }

    override CommandResult createDirectory(string tenantId, CreateDirectoryRequest request) {
        // Hier hast du Zugriff auf die tenantId
        logInfo("Anfrage für Tenant-ID: %s, CreateDirectoryRequest: %s", tenantId, request);

        if (tenantId.length == 0) {
            throw new HTTPStatusException(HTTPStatus.badRequest, "Missing X-Tenant-ID header");
        }

        request.tenantId = TenantId(tenantId);
        // Deine Logik zum Erstellen eines Verzeichnisses gefiltert nach Tenant...
        return usecase.createDirectory(request);
    }
}
