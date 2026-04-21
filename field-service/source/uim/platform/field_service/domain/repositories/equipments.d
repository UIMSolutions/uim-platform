/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.repositories.equipments;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

interface EquipmentRepository : ITenantRepository!(Equipment, EquipmentId) {

    size_t countByCustomer(CustomerId customerId);
    Equipment[] findByCustomer(CustomerId customerId);
    void removeByCustomer(CustomerId customerId);

    size_t countByType(EquipmentType equipmentType);
    Equipment[] findByType(EquipmentType equipmentType);
    void removeByType(EquipmentType equipmentType);

    size_t countByStatus(EquipmentStatus status);
    Equipment[] findByStatus(EquipmentStatus status);
    void removeByStatus(EquipmentStatus status);

}
