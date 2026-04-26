/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.memory.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryEquipmentRepository : TenantRepository!(Equipment, EquipmentId), EquipmentRepository {

    size_t countByCustomer(CustomerId customerId) {
        return findByCustomer(customerId).length;
    }
    Equipment[] filterByCustomer(Equipment[] equipment, CustomerId customerId) {
        return equipment.filter!(e => e.customerId == customerId).array;
    }

    Equipment[] findByCustomer(CustomerId customerId) {
        return filterByCustomer(findAll(), customerId);
    }
    void removeByCustomer(CustomerId customerId) {
        findByCustomer(customerId).each!(e => remove(e));
    }

        size_t countByType(EquipmentType equipmentType) {
            return findByType(equipmentType).length;
        }

        Equipment[] filterByType(Equipment[] equipment, EquipmentType equipmentType) {
            return equipment.filter!(e => e.equipmentType == equipmentType).array;
        }

    Equipment[] findByType(EquipmentType equipmentType) {
        return filterByType(findAll(), equipmentType);
    }
    void removeByType(EquipmentType equipmentType) {
        findByType(equipmentType).each!(e => remove(e));
    }

    size_t countByStatus(EquipmentStatus status) {
        return findByStatus(status).length;
    }
    Equipment[] filterByStatus(Equipment[] equipment, EquipmentStatus status) {
        return equipment.filter!(e => e.status == status).array;
    }
    Equipment[] findByStatus(EquipmentStatus status) {
        return filterByStatus(findAll(), status);
    }
    void removeByStatus(EquipmentStatus status) {
        findByStatus(status).each!(e => remove(e));
    }

}
