/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.process_automation.domain.ports.repositories.visibilities;

import uim.platform.process_automation.domain.types;
import uim.platform.process_automation.domain.entities.visibility;

interface VisibilityRepository {
    Visibility findById(VisibilityId id);
    Visibility[] findByTenant(TenantId tenantId);
    void save(Visibility v);
    void update(Visibility v);
    void remove(VisibilityId id);
    long countByTenant(TenantId tenantId);
}
