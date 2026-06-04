module uim.platform.management.presentation.rest.interfaces.event;

import uim.platform.management;

mixin(ShowModule!());

@safe:
interface IEnvironmentEventApi {
    // GET /rest/v1/events
    EnvironmentEventId[] getEvents();

    // GET /rest/v1/events/:id
    EnvironmentEventId getEvent(string id);
}