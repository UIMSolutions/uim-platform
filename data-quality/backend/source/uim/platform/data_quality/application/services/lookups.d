/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Reference data access for validation (referenceData rules) and
/// cleansing (enrich rules). Values of a reference dataset are loaded once
/// per run and indexed.
module uim.platform.data_quality.application.services.lookups;

import uim.platform.data_quality;

mixin(ShowModule!());

@safe:

class ReferenceData {
  protected IRecordRepository records;
  protected TenantId tenant;
  protected bool[string][string] valueSets; /// "<dataset>|<field>" → values
  protected string[string][string] maps; /// "<dataset>|<key>|<value>" → key → value

  this(IRecordRepository records, TenantId tenant) {
    this.records = records;
    this.tenant = tenant;
  }

  /// Does value occur in field of dataset? (trimmed, exact)
  bool contains(string dataset, string field, string value) @trusted {
    auto k = dataset ~ "|" ~ field;
    if (k !in valueSets) {
      bool[string] set;
      foreach (r; records.findByDataset(tenant, DatasetId(dataset))) {
        auto v = r.field(field).strip;
        if (v.length)
          set[v] = true;
      }
      valueSets[k] = set;
    }
    return (value.strip in valueSets[k]) !is null;
  }

  /// valueField of the first record of dataset whose keyField equals key.
  bool lookup(string dataset, string keyField, string key, string valueField, out string value) @trusted {
    auto k = dataset ~ "|" ~ keyField ~ "|" ~ valueField;
    if (k !in maps) {
      string[string] m;
      foreach (r; records.findByDataset(tenant, DatasetId(dataset))) {
        auto kv = r.field(keyField).strip;
        if (kv.length && kv !in m)
          m[kv] = r.field(valueField);
      }
      maps[k] = m;
    }
    if (auto v = key.strip in maps[k]) {
      value = *v;
      return true;
    }
    return false;
  }

  ReferenceLookup containsDelegate() {
    return &contains;
  }

  EnrichmentLookup lookupDelegate() {
    return &lookup;
  }
}
