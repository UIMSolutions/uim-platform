/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.usecases.manage.screen_sets;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

class ManageScreenSetsUseCase {
    private ScreenSetRepository repo;

    this(ScreenSetRepository repo) {
        this.repo = repo;
    }

    ScreenSet getScreenSet(TenantId tenantId, ScreenSetId id) {
        return repo.findById(tenantId, id);
    }

    ScreenSet[] listScreenSets(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    ScreenSet[] listActive(TenantId tenantId) {
        return repo.findActive(tenantId);
    }

    CommandResult createScreenSet(ScreenSetDTO dto) {
        ScreenSet ss;
        ss.initEntity(dto.tenantId, dto.createdBy);
        ss.name = dto.name;
        ss.description = dto.description;
        ss.htmlContent = dto.htmlContent;
        ss.cssContent = dto.cssContent;
        ss.jsContent = dto.jsContent;
        ss.locale = dto.locale;
        ss.version_ = dto.version_;
        ss.status = ScreenSetStatus.draft;

        import std.conv : to;
        try { ss.flowType = dto.flowType.to!ScreenSetFlowType; }
        catch (Exception) { return CommandResult(false, "", "Invalid flow type"); }

        if (!IdentityValidator.isValidScreenSet(ss))
            return CommandResult(false, "", "Invalid screen set data");

        repo.save(ss);
        return CommandResult(true, ss.id.value, "");
    }

    CommandResult updateScreenSet(ScreenSetDTO dto) {
        auto existing = repo.findById(dto.tenantId, dto.screenSetId);
        if (existing.isNull)
            return CommandResult(false, "", "Screen set not found");

        if (dto.name.length > 0) existing.name = dto.name;
        if (dto.description.length > 0) existing.description = dto.description;
        if (dto.htmlContent.length > 0) existing.htmlContent = dto.htmlContent;
        if (dto.cssContent.length > 0) existing.cssContent = dto.cssContent;
        if (dto.jsContent.length > 0) existing.jsContent = dto.jsContent;
        if (dto.locale.length > 0) existing.locale = dto.locale;
        if (dto.version_.length > 0) existing.version_ = dto.version_;
        if (!dto.updatedBy.isNull) existing.updatedBy = dto.updatedBy;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteScreenSet(TenantId tenantId, ScreenSetId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Screen set not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
