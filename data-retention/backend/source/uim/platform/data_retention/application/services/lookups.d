/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reference counts over the repositories (IDrLookups).
module uim.platform.data_retention.application.services.lookups;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

class DrLookupsService : IDrLookups {
  protected DrRepositories repos;

  this(DrRepositories repos) {
    this.repos = repos;
  }

  long[string] dataSubjectCounts(TenantId t, string attribute) {
    long[string] counts;
    foreach (s; repos.dataSubjects.findAll(t)) {
      string key;
      switch (attribute) {
      case "applicationGroupId":
        key = s.applicationGroupId.value;
        break;
      case "businessPurposeId":
        key = s.businessPurposeId.value;
        break;
      case "legalGroundId":
        key = s.legalGroundId.value;
        break;
      case "dataSubjectRoleId":
        key = s.dataSubjectRoleId.value;
        break;
      case "legalEntityId":
        key = s.legalEntityId.value;
        break;
      default:
        throw DataRetentionException.invalid("Data subjects cannot be counted by '" ~ attribute ~ "'");
      }
      if (key.length)
        counts[key] = counts.get(key, 0) + 1;
    }
    return counts;
  }

  long[string] businessPurposeCounts(TenantId t, string attribute) {
    long[string] counts;
    foreach (p; repos.businessPurposes.findAll(t)) {
      string key;
      switch (attribute) {
      case "applicationGroupId":
        key = p.applicationGroupId.value;
        break;
      case "dataSubjectRoleId":
        key = p.dataSubjectRoleId.value;
        break;
      case "legalEntityId":
        key = p.legalEntityId.value;
        break;
      default:
        throw DataRetentionException.invalid("Business purposes cannot be counted by '" ~ attribute ~ "'");
      }
      if (key.length)
        counts[key] = counts.get(key, 0) + 1;
    }
    return counts;
  }
}
