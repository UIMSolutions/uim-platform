/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.responsibility.application.usecases.manage.responsibility_definitions;

import uim.platform.responsibility;

mixin(ShowModule!());

@safe:

class ManageResponsibilityDefinitionsUseCase {
    private ResponsibilityDefinitionRepository repo;

    this(ResponsibilityDefinitionRepository repo) { this.repo = repo; }

    ResponsibilityDefinition getDefinition(TenantId tenantId, ResponsibilityDefinitionId id) {
        return repo.findById(tenantId, id);
    }

    ResponsibilityDefinition[] listDefinitions(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ResponsibilityDefinition[] listDefinitionsByContext(TenantId tenantId, string contextId) {
        return repo.findByContext(tenantId, contextId);
    }

    CommandResult createDefinition(ResponsibilityDefinitionDTO dto) {
        ResponsibilityDefinition d;
        d.initEntity(dto.tenantId, dto.createdBy);
        d.id          = dto.definitionId;
        d.name        = dto.name;
        d.description = dto.description;
        d.contextId   = dto.contextId;
        d.ruleId      = dto.ruleId;
        d.teamId      = dto.teamId;
        d.status      = parseDefStatus(dto.status);
        d.scope_      = parseScope(dto.scope_);
        d.validFrom   = dto.validFrom;
        d.validTo     = dto.validTo;
        if (d.name.length == 0)
            return CommandResult(false, "", "Definition name is required");
        if (d.contextId.length == 0)
            return CommandResult(false, "", "contextId is required");
        repo.save(d);
        return CommandResult(true, d.id.value, "");
    }

    CommandResult updateDefinition(ResponsibilityDefinitionDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.definitionId);
        if (existing.isNull)
            return CommandResult(false, "", "Definition not found");
        if (dto.name.length > 0)        existing.name        = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.teamId.length > 0)      existing.teamId      = dto.teamId;
        if (dto.ruleId.length > 0)      existing.ruleId      = dto.ruleId;
        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteDefinition(TenantId tenantId, ResponsibilityDefinitionId id) {
        auto e = repo.findById(tenantId, id);
        if (e.isNull)
            return CommandResult(false, "", "Definition not found");
        repo.remove(e);
        return CommandResult(true, e.id.value, "");
    }

    private static DefinitionStatus parseDefStatus(string s) {
        
        try { return s.to!DefinitionStatus; } catch (Exception) { return DefinitionStatus.active; }
    }

    private static AssignmentScope parseScope(string s) {
        
        try { return s.to!AssignmentScope; } catch (Exception) { return AssignmentScope.global_; }
    }
}
