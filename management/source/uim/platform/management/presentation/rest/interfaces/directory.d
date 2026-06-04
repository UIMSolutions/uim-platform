module uim.platform.management.presentation.rest.interfaces.directory;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IDirectoryApi {
    // GET /rest/v1/directories
    Directory[] getDirectories();

    // GET /rest/v1/directories/:id
    Directory getDirectory(string id);
}