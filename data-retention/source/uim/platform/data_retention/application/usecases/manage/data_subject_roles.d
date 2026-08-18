/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.application.usecases.manage.data_subject_roles;
import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class ManageDataSubjectRolesUseCase {
    private IDataSubjectRoleRepository repo;

    this(IDataSubjectRoleRepository repo) {
        this.repo = repo;
    }

    CommandResult createDataSubjectRole(CreateDataSubjectRoleRequest req) {
        import std.uuid : randomUUID;

        if (req.name.isEmpty)
            return CommandResult(false, "", "Data subject role name is required");

        DataSubjectRole dsr;
        dsr.id = DataSubjectRoleId(generateId);
        dsr.tenantId = req.tenantId;
        dsr.name = req.name;
        dsr.description = req.description;
        dsr.isActive = true;
        dsr.createdBy = req.createdBy;
        dsr.createdAt = clockSeconds();

        repo.save(dsr);
        return CommandResult(true, dsr.id.value, "");
    }

    CommandResult updateDataSubjectRole(TenantId tenantId, DataSubjectRoleId id, UpdateDataSubjectRoleRequest req) {
        auto dsr = repo.findById(tenantId, id);
        if (dsr.isNull)
            return CommandResult(false, "", "Data subject role not found");

        if (req.name.length > 0)
            dsr.name = req.name;
        if (req.description.length > 0)
            dsr.description = req.description;
        dsr.isActive = req.isActive;
        dsr.updatedAt = clockSeconds();

        repo.update(dsr);
        return CommandResult(true, id.value, "");
    }

    bool hasDataSubjectRole(TenantId tenantId, DataSubjectRoleId id) {
        return repo.existsById(tenantId, id);
    }

    DataSubjectRole getDataSubjectRole(TenantId tenantId, DataSubjectRoleId id) {
        return repo.findById(tenantId, id);
    }

    DataSubjectRole[] listDataSubjectRoles(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    CommandResult deleteDataSubjectRole(TenantId tenantId, DataSubjectRoleId id) {
        auto entity = repo.findById(tenantId, id);
        if (entity.isNull)
            return CommandResult(false, "", "Data subject role not found");

        repo.remove(entity);
        return CommandResult(true, entity.id.value, "");
    }
}
