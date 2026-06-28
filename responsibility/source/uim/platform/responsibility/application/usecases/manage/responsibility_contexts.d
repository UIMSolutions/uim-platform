/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.responsibility_contexts;

import uim.platform.responsibility;

// mixin(ShowModule!());

@safe:

class ManageResponsibilityContextsUseCase {
    private ResponsibilityContextRepository repo;

    this(ResponsibilityContextRepository repo) { this.repo = repo; }

    ResponsibilityContext getContext(TenantId tenantId, ResponsibilityContextId id) {
        return repo.findById(tenantId, id);
    }

    ResponsibilityContext[] listContexts(TenantId tenantId) {
        return repo.find(tenantId);
    }

    CommandResult createContext(ResponsibilityContextDTO dto) {
        ResponsibilityContext c;
        c.initEntity(dto.tenantId, dto.createdBy);
        c.id          = dto.contextId;
        c.name        = dto.name;
        c.description = dto.description;
        c.objectType  = dto.objectType;
        c.namespace_  = dto.namespace_;
        c.status      = parseContextStatus(dto.status);
        if (c.name.length == 0)
            return CommandResult(false, "", "Context name is required");
        repo.save(c);
        return CommandResult(true, c.id.value, "");
    }

    CommandResult updateContext(ResponsibilityContextDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.contextId);
        if (existing.isNull)
            return CommandResult(false, "", "Context not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.objectType.length > 0)  existing.objectType  = dto.objectType;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteContext(TenantId tenantId, ResponsibilityContextId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Context not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static ContextStatus parseContextStatus(string s) {
        
        try { return s.to!ContextStatus; } catch (Exception) { return ContextStatus.active; }
    }
}
