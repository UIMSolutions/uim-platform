/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.infrastructure.persistence.repositories.equipment;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

class MemoryEquipmentRepository : TenantRepository!(Equipment, EquipmentId), EquipmentRepository {

    size_t countByCustomer(TenantId tenantId, CustomerId customerId) {
        return findByCustomer(tenantId, customerId).length;
    }
    Equipment[] filterByCustomer(Equipment[] equipment, CustomerId customerId) {
        return equipment.filter!(e => e.customerId == customerId).array;
    }

    Equipment[] findByCustomer(TenantId tenantId, CustomerId customerId) {
        return filterByCustomer(findByTenant(tenantId), customerId);
    }
    void removeByCustomer(TenantId tenantId, CustomerId customerId) {
        findByCustomer(tenantId, customerId).each!(e => remove(e));
    }

        size_t countByType(TenantId tenantId, EquipmentType equipmentType) {
            return findByType(tenantId,     equipmentType).length;
        }

        Equipment[] filterByType(Equipment[] equipment, EquipmentType equipmentType) {
            return equipment.filter!(e => e.equipmentType == equipmentType).array;
        }

    Equipment[] findByType(TenantId tenantId, EquipmentType equipmentType) {
        return filterByType(findByTenant(tenantId), equipmentType);
    }
    void removeByType(TenantId tenantId, EquipmentType equipmentType) {
        findByType(tenantId, equipmentType).each!(e => remove(e));
    }

    size_t countByStatus(TenantId tenantId, EquipmentStatus status) {
        return findByStatus(tenantId, status).length;
    }
    Equipment[] filterByStatus(Equipment[] equipment, EquipmentStatus status) {
        return equipment.filter!(e => e.status == status).array;
    }
    Equipment[] findByStatus(TenantId tenantId, EquipmentStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }
    void removeByStatus(TenantId tenantId, EquipmentStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

}
