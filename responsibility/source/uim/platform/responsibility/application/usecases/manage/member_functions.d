/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.member_functions;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class ManageMemberFunctionsUseCase {
    private MemberFunctionRepository repo;

    this(MemberFunctionRepository repo) { this.repo = repo; }

    MemberFunction getFunction(TenantId tenantId, MemberFunctionId id) {
        return repo.find(tenantId, id);
    }

    MemberFunction[] listFunctions(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult createFunction(MemberFunctionDTO dto) {
        MemberFunction f;
        f.initEntity(dto.tenantId, dto.createdBy);
        f.id          = dto.functionId;
        f.name        = dto.name;
        f.description = dto.description;
        f.code        = dto.code;
        f.status      = parseFunctionStatus(dto.status);
        if (f.name.length == 0)
            return CommandResult(false, "", "Function name is required");
        repo.save(f);
        return CommandResult(true, f.id.value, "");
    }

    CommandResult updateFunction(MemberFunctionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.functionId);
        if (existing.isNull)
            return CommandResult(false, "", "Function not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.code.length > 0)        existing.code        = dto.code;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteFunction(TenantId tenantId, MemberFunctionId id) {
        auto e = repo.find(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Function not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static FunctionStatus parseFunctionStatus(string s) {
        
        try { return s.to!FunctionStatus; } catch (Exception) { return FunctionStatus.active; }
    }
}
