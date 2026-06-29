/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.glossary_entries;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

class ManageGlossaryEntriesUseCase {
    private GlossaryEntryRepository repo;

    this(GlossaryEntryRepository repo) {
        this.repo = repo;
    }

    CommandResult createEntry(CreateGlossaryEntryRequest r) {
        if (r.sourceTerm.length == 0)
            return CommandResult(false, "", "Source term is required");
        if (r.targetTerm.length == 0)
            return CommandResult(false, "", "Target term is required");
        if (r.sourceLanguage.length == 0 || r.targetLanguage.length == 0)
            return CommandResult(false, "", "Source and target languages are required");

        GlossaryEntry e;
        e.initEntity(r.tenantId);
        e.sourceLanguage = r.sourceLanguage;
        e.targetLanguage = r.targetLanguage;
        e.sourceTerm = r.sourceTerm;
        e.targetTerm = r.targetTerm;
        e.domainName = r.domainName;
        e.context = r.context;
        e.mandatory = r.mandatory;

        repo.save(e);
        return CommandResult(true, e.id.value, "");
    }

    GlossaryEntry[] listEntries(TenantId tenantId) {
        return repo.findByTenant(tenantId);
    }

    GlossaryEntry getEntry(TenantId tenantId, GlossaryEntryId id) {
        return repo.findById(tenantId, id);
    }

    CommandResult updateEntry(UpdateGlossaryEntryRequest r) {
        auto existing = repo.find(r.tenantId, r.entryId);
        if (existing.isNull)
            return CommandResult(false, "", "Glossary entry not found");

        if (r.targetTerm.length > 0)   existing.targetTerm = r.targetTerm;
        if (r.domainName.length > 0)   existing.domainName = r.domainName;
        if (r.context.length > 0)      existing.context = r.context;
        existing.mandatory = r.mandatory;

        repo.update(existing);
        return CommandResult(true, existing.id.value, "");
    }

    CommandResult deleteEntry(TenantId tenantId, GlossaryEntryId id) {
        auto existing = repo.findById(tenantId, id);
        if (existing.isNull)
            return CommandResult(false, "", "Glossary entry not found");

        repo.remove(existing);
        return CommandResult(true, existing.id.value, "");
    }
}
