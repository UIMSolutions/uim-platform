/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.glossary_entry;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

/// A company-specific translation memory entry (company MLTR).
/// Provides preferred or mandatory translations for domain-specific terms.
struct GlossaryEntry {
    mixin TenantEntity!(GlossaryEntryId);

    /// BCP-47 source language tag, e.g. "en"
    string sourceLanguage;
    /// BCP-47 target language tag, e.g. "de"
    string targetLanguage;
    /// Original term or phrase
    string sourceTerm;
    /// Preferred translation of the term
    string targetTerm;
    /// Translation domain (e.g. "IT", "HR", "Finance")
    string domainName;
    /// Optional usage context or note
    string context;
    /// Whether this entry is mandatory (must be used by the translation engine)
    bool mandatory;

    Json toJson() const {
        return entityToJson
            .set("sourceLanguage", sourceLanguage)
            .set("targetLanguage", targetLanguage)
            .set("sourceTerm", sourceTerm)
            .set("targetTerm", targetTerm)
            .set("domainName", domainName)
            .set("context", context)
            .set("mandatory", mandatory);
    }
}
