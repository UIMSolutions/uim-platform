module uim.platform.management.presentation.rest.interfaces.environment;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IEnvironmentApi {
    // GET /rest/v1/environments
    Environment[] getEnvironments();

    // GET /rest/v1/environments/:id
    Environment getEnvironment(string id);
}