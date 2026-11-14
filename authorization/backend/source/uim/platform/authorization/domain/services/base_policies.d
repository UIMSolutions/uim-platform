/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The base policies every application gets (AMS "base policies").
module uim.platform.authorization.domain.services.base_policies;

import uim.platform.authorization;

mixin(ShowModule!());

@safe:

struct BasePolicyTemplate {
  string name;
  string description;
  string resource;
  string action;
}

/// admin: everything · reader: read everything · support: read incidents.
immutable BasePolicyTemplate[] basePolicyTemplates = [
  BasePolicyTemplate("admin", "Administrative full access", "*", "*"),
  BasePolicyTemplate("reader", "Read-only access to all resources", "*", "Read"),
  BasePolicyTemplate("support", "Support read access for incident-like resources", "Incident", "Read"),
];
