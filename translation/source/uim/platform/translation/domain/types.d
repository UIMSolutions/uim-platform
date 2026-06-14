/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.domain.types;

import uim.platform.translation;

// mixin(ShowModule!());

@safe:

// --- ID value types ---

struct TranslationProjectId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct GlossaryEntryId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct TranslationJobId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct TranslationResultId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
