/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Glossary enforcement: glossary terms are protected by placeholders before
/// machine translation and replaced by their target terms afterwards, so the
/// engine can neither translate nor break them.
module uim.platform.translation.domain.services.glossary;

import std.ascii : isAlphaNum, asciiLower = toLower;
import uim.platform.translation;

mixin(ShowModule!());

@safe:

/// A text with glossary terms replaced by placeholders.
struct ProtectedText {
  string text;
  string[] targets; /// target term of placeholder i
}

/// Placeholder i ("⟦0⟧"); engines keep non-word characters unchanged.
string placeholder(size_t i) {
  return "⟦" ~ i.to!string ~ "⟧";
}

/// The glossary entries that apply to a request: same language pair, matching
/// domain (entries without domain apply everywhere); mandatory entries always,
/// optional entries only for the companyMltr provider. Longer terms first.
GlossaryEntry[] applicableEntries(const GlossaryEntry[] entries, string sourceLanguage,
    string targetLanguage, string domainName, TranslationProvider provider) {
  GlossaryEntry[] result;
  foreach (e; entries) {
    if (primaryLanguage(e.sourceLanguage) != primaryLanguage(sourceLanguage)
        || primaryLanguage(e.targetLanguage) != primaryLanguage(targetLanguage))
      continue;
    if (e.domainName.length > 0 && e.domainName != domainName)
      continue;
    if (!e.mandatory && provider != TranslationProvider.companyMltr)
      continue;
    result ~= e;
  }
  result.sort!((a, b) => a.sourceTerm.length > b.sourceTerm.length);
  return result;
}

/// ASCII lower case; keeps byte offsets of UTF-8 text unchanged.
private string lowerAscii(string s) {
  auto buf = new char[s.length];
  foreach (i, char c; s)
    buf[i] = asciiLower(c);
  return (() @trusted => cast(string) buf)();
}

/// True if text[start .. end] is a whole word (no letters/digits around it).
private bool wholeWord(string text, size_t start, size_t end) {
  return (start == 0 || !isAlphaNum(text[start - 1])) && (end >= text.length || !isAlphaNum(text[end]));
}

/// Replace whole-word occurrences of the source terms by placeholders.
ProtectedText protectTerms(string text, const GlossaryEntry[] entries) {
  ProtectedText result;
  result.text = text;
  foreach (e; entries) {
    if (e.sourceTerm.length == 0)
      continue;
    auto haystack = e.caseSensitive ? result.text : lowerAscii(result.text);
    auto needle = e.caseSensitive ? e.sourceTerm : lowerAscii(e.sourceTerm);
    string rebuilt;
    size_t from, hits;
    for (;;) {
      auto at = haystack[from .. $].indexOf(needle);
      if (at < 0)
        break;
      auto start = from + at, end = start + needle.length;
      if (wholeWord(result.text, start, end)) {
        rebuilt ~= result.text[from .. start] ~ placeholder(result.targets.length);
        hits++;
      } else
        rebuilt ~= result.text[from .. end];
      from = end;
    }
    if (hits == 0)
      continue;
    result.text = rebuilt ~ result.text[from .. $];
    result.targets ~= e.targetTerm;
  }
  return result;
}

/// Put the target terms in place of the placeholders. `hits` counts replacements.
string restoreTerms(string translated, const string[] targets, out int hits) {
  auto result = translated;
  foreach (i, target; targets) {
    auto p = placeholder(i);
    while (result.indexOf(p) >= 0) {
      auto at = result.indexOf(p);
      result = result[0 .. at] ~ target ~ result[at + p.length .. $];
      hits++;
    }
  }
  return result;
}

///
unittest {
  GlossaryEntry invoice;
  invoice.sourceLanguage = "en";
  invoice.targetLanguage = "de";
  invoice.sourceTerm = "invoice";
  invoice.targetTerm = "Faktura";
  invoice.mandatory = true;
  GlossaryEntry optional = invoice;
  optional.sourceTerm = "customer";
  optional.targetTerm = "Kunde";
  optional.mandatory = false;
  GlossaryEntry hr = invoice;
  hr.sourceTerm = "payroll";
  hr.domainName = "HR";

  auto list = applicableEntries([invoice, optional, hr], "en", "de-DE", "FI", TranslationProvider.machineMt);
  assert(list.length == 1 && list[0].sourceTerm == "invoice");
  assert(applicableEntries([invoice, optional, hr], "en", "de", "HR", TranslationProvider.companyMltr).length == 3);
  assert(applicableEntries([invoice], "en", "fr", "", TranslationProvider.mltr).length == 0);

  auto p = protectTerms("Post Invoice; invoices stay. INVOICE", [invoice]);
  assert(p.text == "Post ⟦0⟧; invoices stay. ⟦0⟧", p.text);
  int hits;
  assert(restoreTerms(p.text, p.targets, hits) == "Post Faktura; invoices stay. Faktura" && hits == 2);
  assert(protectTerms("no match", [invoice]).targets.length == 0);
}
