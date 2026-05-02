/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.infrastructure.persistence.memory.resource_groups;

// import uim.platform.ai_core.domain.types;
// import uim.platform.ai_core.domain.entities.resource_group;
// import uim.platform.ai_core.domain.ports.repositories.resource_groups;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.ai_core;

mixin(ShowModule!()); 

@safe:
class MemoryResourceGroupRepository : TenantRepository!(ResourceGroup, ResourceGroupId), ResourceGroupRepository {

  // TODO: Implement methods for finding and removing resource groups by tenant, if needed.
}
