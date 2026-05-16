module uim.platform.ai_launchpad.infrastructure.helpers.connections;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

T[] filterByConnection(T)(T[] entities, ConnectionId connectionId) {
    return entities.filter!(c => c.connectionId == connectionId).array;
}