/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.rfc.application.usecases.manage.function_modules;

import uim.platform.rfc;

// mixin(ShowModule!());
@safe:

class ManageFunctionModulesUseCase {

    private FunctionModuleRepository _repo;

    this(FunctionModuleRepository repo) { _repo = repo; }

    CommandResult createFunctionModule(CreateFunctionModuleRequest req) {
        if (_repo.existsById(req.tenantId, req.id))
            return CommandResult(false, req.id, "Function module already exists: " ~ req.id);

        auto fm = FunctionModule(req.tenantId, req.id);
        fm.functionGroup = req.functionGroup;
        fm.shortText = req.shortText;
        fm.remoteEnabled = req.remoteEnabled.length > 0 ? req.remoteEnabled : "ENABLED";
        foreach (p; req.parameters) fm.parameters ~= RfcParameter(p.name, p.direction, p.typeName,
                                                                    p.defaultValue, p.optional, p.description);

        if (!_repo.save(fm))
            return CommandResult(false, "", "Failed to save function module");
        return CommandResult(true, fm.id, "");
    }

    FunctionModule getFunctionModule(TenantId tenantId, FunctionModuleId id) {
        return _repo.findById(tenantId, id);
    }

    FunctionModule[] listFunctionModules(TenantId tenantId) {
        return _repo.find(tenantId);
    }

    FunctionModule[] listByFunctionGroup(TenantId tenantId, string functionGroup) {
        return _repo.findByFunctionGroup(tenantId, functionGroup);
    }

    CommandResult updateFunctionModule(UpdateFunctionModuleRequest req) {
        
        auto fm = _repo.findById(req.tenantId, req.id);
        if (fm.isNull())
            return CommandResult(false, req.id, "Function module not found: " ~ req.id);

        fm.shortText     = req.shortText;
        fm.remoteEnabled = req.remoteEnabled;
        fm.active        = req.active;
        fm.parameters    = [];
        foreach (p; req.parameters) fm.parameters ~= RfcParameter(p.name, p.direction, p.typeName,
                                                                    p.defaultValue, p.optional, p.description);
        fm.updatedAt = MonoTime.currTime.ticks;

        if (!_repo.update(fm))
            return CommandResult(false, fm.id, "Failed to update function module");
        return CommandResult(true, fm.id, "");
    }

    CommandResult deleteFunctionModule(TenantId tenantId, FunctionModuleId id) {
        auto fm = _repo.findById(tenantId, id);
        if (fm.isNull())
            return CommandResult(false, id, "Function module not found: " ~ id);
        if (!_repo.remove(tenantId, id))
            return CommandResult(false, id, "Failed to delete function module");
        return CommandResult(true, id, "");
    }

    size_t countFunctionModules(TenantId tenantId) {
        return _repo.count(tenantId);
    }
}
