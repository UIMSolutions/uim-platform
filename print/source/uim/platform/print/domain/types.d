/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.print.domain.types;

import uim.platform.print;

mixin(ShowModule!());

@safe:

struct PrintQueueId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PrintTaskId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PrinterId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PrintDocumentId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}

struct PrintClientId {
    string value;
    this(string value) { this.value = value; }
    mixin DomainId;
}
