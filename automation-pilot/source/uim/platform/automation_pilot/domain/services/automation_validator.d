/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.domain.services.automation_validator;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

struct AutomationValidator {
    static bool isValidCatalog(Catalog c) {
        return c.name.length > 0 && c.tenantId.value.length > 0;
    }

    static bool isValidCommand(Command cmd) {
        return cmd.tenantId.value.length > 0 && cmd.catalogId.value.length > 0 && cmd.name.length > 0;
    }

    static bool isValidCommandInput(CommandInput ci) {
        return ci.tenantId.value.length > 0 && ci.name.length > 0;
    }

    static bool isValidExecution(Execution e) {
        return e.tenantId.value.length > 0 && e.commandId.value.length > 0;
    }

    static bool isValidScheduledExecution(ScheduledExecution se) {
        return se.tenantId.value.length > 0 && se.commandId.value.length > 0;
    }

    static bool isValidTrigger(Trigger t) {
        return t.tenantId.value.length > 0 && t.commandId.value.length > 0 && t.name.length > 0;
    }

    static bool isValidServiceAccount(ServiceAccount sa) {
        return sa.tenantId.value.length > 0 && sa.name.length > 0;
    }

    static bool isValidContentConnector(ContentConnector cc) {
        return cc.tenantId.value.length > 0 && cc.name.length > 0 && cc.repositoryUrl.length > 0;
    }
}
