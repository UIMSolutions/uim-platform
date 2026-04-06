/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.collaboration_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface CollaborationRepository {
    Collaboration[] findAll();
    Collaboration* findById(CollaborationId id);
    Collaboration[] findByTenant(TenantId tenantId);
    Collaboration[] findByProduct(string productId);
    Collaboration[] findByStatus(CollaborationStatus status);
    Collaboration[] findByAssignee(string assignedTo);
    void save(Collaboration collab);
    void update(Collaboration collab);
    void remove(CollaborationId id);
}
