/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.services.field_service_validator;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct FieldServiceValidator {
    static bool isValidServiceCall(ServiceCall sc) {
        return sc.subject.length > 0 && sc.tenantId.length > 0 && sc.customerId.length > 0;
    }

    static bool isValidActivity(Activity a) {
        return a.subject.length > 0 && a.tenantId.length > 0 && a.serviceCallId.length > 0;
    }

    static bool isValidAssignment(Assignment a) {
        return a.tenantId.length > 0 && a.activityId.length > 0 && a.technicianId.length > 0;
    }

    static bool isValidEquipment(Equipment e) {
        return e.name.length > 0 && e.tenantId.length > 0 && e.serialNumber.length > 0;
    }

    static bool isValidTechnician(Technician t) {
        return t.firstName.length > 0 && t.lastName.length > 0 && t.tenantId.length > 0;
    }

    static bool isValidCustomer(Customer c) {
        return c.name.length > 0 && c.tenantId.length > 0;
    }

    static bool isValidSkill(Skill s) {
        return s.name.length > 0 && s.tenantId.length > 0 && s.technicianId.length > 0;
    }

    static bool isValidSmartform(Smartform sf) {
        return sf.name.length > 0 && sf.tenantId.length > 0;
    }
}
