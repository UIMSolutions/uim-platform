/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.entities.glossary_entry;

import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A company glossary entry (company MLTR): the preferred translation of a
/// term. Mandatory entries are enforced by every provider; optional entries
/// are applied by the companyMltr provider.
struct GlossaryEntry {
  mixin TenantEntity!GlossaryEntryId;

  string name; /// derived: "<sourceTerm> (<source>→<target>)"
  string sourceLanguage;
  string targetLanguage;
  string sourceTerm;
  string targetTerm;
  string domainName; /// "" = every domain
  string context;
  bool mandatory;
  bool caseSensitive;
}
