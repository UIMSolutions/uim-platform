/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.application.usecases.manage.glossary;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// Interactor: company glossary. A term is unique per language pair and domain.
class ManageGlossaryUseCase
  : ResourceUseCase!(GlossaryEntry, GlossaryEntryId, CreateGlossaryEntryRequest, UpdateGlossaryEntryRequest),
  IManageGlossaryUseCase {

  this(TranslationRepositories repos, EventRecorder events) {
    super(repos, repos.glossary, events, "Glossary entry", "translation.glossary");
  }

  override protected GlossaryEntry build(CreateGlossaryEntryRequest r) {
    auto e = GlossaryEntry(r.tenantId);
    assignMatching(e, r.spec);
    check(e);
    return e;
  }

  override protected void apply(ref GlossaryEntry e, GlossaryEntrySpec spec) {
    assignMatching(e, spec);
    check(e);
  }

  protected void check(ref GlossaryEntry e) {
    e.sourceLanguage = requireLanguage("Source language", e.sourceLanguage);
    e.targetLanguage = requireLanguage("Target language", e.targetLanguage);
    validateLanguagePair(e.sourceLanguage, e.targetLanguage);
    e.sourceTerm = e.sourceTerm.strip;
    e.targetTerm = e.targetTerm.strip;
    validate(e.sourceTerm.length > 0, "Source term is required");
    validate(e.targetTerm.length > 0, "Target term is required");
    validate(e.sourceTerm.length <= 200 && e.targetTerm.length <= 200, "Terms must not exceed 200 characters");
    e.domainName = requireDomain(e.domainName);
    e.name = glossaryEntryName(e.sourceTerm, e.sourceLanguage, e.targetLanguage);
    ensureUnique(repos.glossary.findByTerm(e.tenantId, e.sourceLanguage, e.targetLanguage, e.sourceTerm,
        e.domainName), e, e.domainName.length ? "domain " ~ e.domainName : "the general glossary");
  }

  GlossaryEntry[] byLanguagePair(TenantId tenantId, string sourceLanguage, string targetLanguage) {
    return repos.glossary.findByLanguagePair(tenantId, sourceLanguage, targetLanguage);
  }
}
