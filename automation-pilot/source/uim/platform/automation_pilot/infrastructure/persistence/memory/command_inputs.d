/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCommandInputRepository : TenantRepository!(CommandInput, CommandInputId), CommandInputRepository {

    size_t countByType(TenantId tenantId, InputType inputType) {
        return findByType(tenantId, inputType).length;
    }

    CommandInput[] findByType(TenantId tenantId, InputType inputType) {
        return filterByType(findByTenant(tenantId), inputType);
    }

    CommandInput[] filterByType(CommandInput[] inputs, InputType inputType) {
        return inputs.filter!(e => e.inputType == inputType).array;
    }

    void removeByType(TenantId tenantId, InputType inputType) {
        findByType(tenantId, inputType).each!(e => remove(e));
    }

}
