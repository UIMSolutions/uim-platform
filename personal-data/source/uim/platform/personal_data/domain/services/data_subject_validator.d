/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.services.data_subject_validator;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct DataSubjectValidator {
    static bool validate(string id, string firstName, string lastName) {
        if (id.length == 0) return false;
        if (firstName.length == 0 && lastName.length == 0) return false;
        return true;
    }

    static bool validateEmail(string email) {
        if (email.length == 0) return false;
        import std.algorithm : canFind;
        return email.canFind("@") && email.canFind(".");
    }
}
