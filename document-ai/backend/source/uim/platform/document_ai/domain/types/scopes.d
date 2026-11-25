/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Authorization scopes (XSUAA local scope names; the built-in JWT login
/// uses the same names).
///   Read     read documents, extraction results, schemas, templates,
///            document types, enrichment data, training jobs and clients
///   Process  upload documents, run the extraction, correct extracted
///            values, confirm and reject documents
///   Manage   maintain schemas and their fields, templates, document types,
///            enrichment data, clients and training jobs (implies Process)
///   Admin    manage the user accounts of the built-in login
module uim.platform.document_ai.domain.types.scopes;

import uim.platform.document_ai;

mixin(ShowModule!());

@safe:

enum string readScope = "Read";
enum string processScope = "Process";
enum string manageScope = "Manage";
enum string adminScope = "Admin";

enum string[] knownScopes = [readScope, processScope, manageScope, adminScope];

/// Validated, de-duplicated scopes in canonical order. Every scope implies
/// Read; Manage implies Process.
string[] normalizeScopes(const string[] scopes) {
  import std.uni : icmp;

  bool[string] wanted;
  foreach (s; scopes) {
    auto t = s.strip;
    if (t.length == 0)
      continue;
    string canonical;
    foreach (k; knownScopes)
      if (icmp(k, t) == 0)
        canonical = k;
    if (canonical.length == 0)
      throw DaiException.invalid("Unknown scope '" ~ t ~ "' (allowed: " ~ knownScopes.join(", ") ~ ")");
    wanted[canonical] = true;
  }
  if (wanted.length)
    wanted[readScope] = true;
  if (manageScope in wanted)
    wanted[processScope] = true;
  string[] result;
  foreach (k; knownScopes)
    if (k in wanted)
      result ~= k;
  return result;
}

///
unittest {
  assert(normalizeScopes(["manage", " admin "]) == ["Read", "Process", "Manage", "Admin"]);
  assert(normalizeScopes(["process"]) == ["Read", "Process"]);
  assert(normalizeScopes([]).length == 0 && normalizeScopes(["Read"]) == ["Read"]);
  assert(failsWith(DaiErrorKind.invalid, () { normalizeScopes(["root"]); }));
}
