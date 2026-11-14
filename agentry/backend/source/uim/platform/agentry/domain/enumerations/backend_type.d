/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.backend_type;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// SAP backend system type for backend connections
enum BackendType {
    // SAP S/4HANA, the next-generation ERP suite from SAP that provides advanced capabilities for digital transformation and intelligent enterprise management
    s4hana,
    // SAP ECC (ERP Central Component), the previous generation ERP suite from SAP that is still widely used in many organizations and provides core ERP functionalities
    ecc,
    // SAP Business Technology Platform (BTP), a cloud-based platform that provides a wide range of services and tools for building, deploying, and managing applications and extensions in the SAP ecosystem
    btp,
    // SAP CRM (Customer Relationship Management), a suite of applications and tools for managing customer relationships, sales, marketing, and service processes in organizations
    crm,
    // Custom backend system, which may indicate a non-SAP system or a custom-built solution that is integrated with the mobile application management platform for specific use cases or requirements
    custom
}

BackendType toBackendType(string value) {
    mixin(EnumSwitch("BackendType", "custom"));
}

BackendType[] toBackendTypes(string[] values) {
    return values.map!toBackendType.array;
}
string toString(BackendType value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "s4hana", "ecc", etc
}
string[] toString(BackendType[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("s4hana".toBackendType == BackendType.s4hana);
    assert("ECC".toBackendType == BackendType.ecc);
    assert("BTP".toBackendType == BackendType.btp);
    assert("crm".toBackendType == BackendType.crm);

    assert("".toBackendType == BackendType.custom);
    assert("unknown".toBackendType == BackendType.custom);

    assert(BackendType.s4hana.toString == "s4hana");
    assert(BackendType.ecc.toString == "ecc");
    assert(BackendType.btp.toString == "btp");
    assert(BackendType.crm.toString == "crm");
    assert(BackendType.custom.toString == "custom");

    assert(["s4hana", "ecc", "btp", "crm", "unknown"].toBackendTypes ==
            [        BackendType.s4hana, BackendType.ecc, BackendType.btp,
                BackendType.crm, BackendType.custom
            ]);
    assert([BackendType.s4hana, BackendType.ecc, BackendType.btp, BackendType.crm,
        BackendType.custom
    ].toString ==
        ["s4hana", "ecc", "btp", "crm", "custom"]);
}
