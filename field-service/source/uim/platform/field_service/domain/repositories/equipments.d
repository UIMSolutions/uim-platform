/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.equipments;

import uim.platform.field_service;

// mixin(ShowModule!());

@safe:

interface EquipmentRepository : ITenantRepository!(Equipment, EquipmentId) {

    size_t countByCustomer(TenantId tenantId, CustomerId customerId);
    Equipment[] findByCustomer(TenantId tenantId, CustomerId customerId);
    void removeByCustomer(TenantId tenantId, CustomerId customerId);

    size_t countByType(TenantId tenantId, EquipmentType equipmentType);
    Equipment[] findByType(TenantId tenantId, EquipmentType equipmentType);
    void removeByType(TenantId tenantId, EquipmentType equipmentType);

    size_t countByStatus(TenantId tenantId, EquipmentStatus status);
    Equipment[] findByStatus(TenantId tenantId, EquipmentStatus status);
    void removeByStatus(TenantId tenantId, EquipmentStatus status);

}
