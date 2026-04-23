/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.automation_pilot.infrastructure.persistence.memory.command_inputs;

import uim.platform.automation_pilot;

mixin(ShowModule!());

@safe:

class MemoryCommandInputRepository : TenantREpository!(CommandInput, CommandInputId), CommandInputRepository {

    size_t countByType(InputType inputType) {
        return findByType(inputType).length;
    }

    CommandInput[] findByType(InputType inputType) {
        return findAll().filter!(e => e.inputType == inputType).array;
    }

    void removeByType(InputType inputType) {
        return findByType(inputType).each!(e => remove(e));
    }

}
