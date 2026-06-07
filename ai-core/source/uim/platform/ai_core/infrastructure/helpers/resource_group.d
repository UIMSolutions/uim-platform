module uim.platform.ai_core.infrastructure.helpers.resource_group;

import uim.platform.ai_core;

// mixin(ShowModule!());

@safe:

T[] filterByResourceGroup(T)(T[] entities, ResourceGroupId rgId) {
    return entities.filter!(entity => entity.resourceGroupId == rgId).array;
}
