/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.infrastructure.persistence.memory.artifacts;

import uim.platform.process_automation;

mixin(ShowModule!());

@safe:
class MemoryArtifactRepository : TenantRepository!(Artifact, ArtifactId), ArtifactRepository {

    size_t countByType(TenantId tenantId, ArtifactType type) {
        return findByType(tenantId, type).length;
    }

    Artifact[] filterByType(Artifact[] items, ArtifactType type) {
        return items.filter!(a => a.type == type).array;
    }

    Artifact[] findByType(TenantId tenantId, ArtifactType type) {
        return filterByType(findByTenant(tenantId), type);
    }

    void removeByType(TenantId tenantId, ArtifactType type) {
        findByType(tenantId, type).each!(a => remove(a));
    }

    size_t countByCategory(TenantId tenantId, string category) {
        return findByCategory(tenantId, category).length;
    }

    Artifact[] filterByCategory(Artifact[] items, string category) {
        return items.filter!(a => a.category == category).array;
    }

    Artifact[] findByCategory(TenantId tenantId, string category) {
        return filterByCategory(findByTenant(tenantId), category);
    }

    void removeByCategory(TenantId tenantId, string category) {
        findByCategory(tenantId, category).each!(a => remove(a));
    }

}
