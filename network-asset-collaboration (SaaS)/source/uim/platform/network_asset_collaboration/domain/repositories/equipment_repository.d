/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.domain.repositories.equipment_repository;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

interface EquipmentRepository {
    Equipment[] findAll();
    Equipment* findById(EquipmentId id);
    Equipment[] findByTenant(TenantId tenantId);
    Equipment[] findByModel(ModelId modelId);
    Equipment[] findByStatus(EquipmentStatus status);
    Equipment[] findByManufacturer(string manufacturer);
    void save(Equipment equipment);
    void update(Equipment equipment);
    void remove(EquipmentId id);
}
