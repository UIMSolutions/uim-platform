/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.feature_flags.domain.entities.flag_variant;

import uim.platform.feature_flags;

mixin(ShowModule!());

@safe:

/// A named value variation of a feature flag.
/// For BOOLEAN flags: key="on"/"off", value="true"/"false".
/// For STRING flags: key is the variant name, value is the string value.
/// For JSON/NUMBER flags: value holds the serialised payload.
struct FlagVariant {
    VariantId id;

    /// Short identifier used in targeting rules and evaluations (e.g. "beta", "on", "v2")
    string key;

    /// Human-readable name
    string name;
    string description;

    /// Serialised value (string, number, or JSON text)
    string value;

    /// Weight used for percentage-based rollouts (0-100 000, millipercent precision)
    uint   weight;

    bool isNull() const { return id.isNull; }
}
