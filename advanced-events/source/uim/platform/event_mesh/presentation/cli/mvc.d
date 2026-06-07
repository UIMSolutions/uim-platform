/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.cli.mvc;

import std.array : appender;
import std.format : format;
import std.stdio : writeln;

import uim.platform.event_mesh;

// mixin(ShowModule!());

@safe:

final class CliBrokerServiceModel {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    BrokerService[] listServices(string tenantId) {
        return usecase.listServices(TenantId(tenantId));
    }
}

final class CliBrokerServiceView {
    string renderList(BrokerService[] services) const {
        auto output = appender!string();
        output.put("Broker Services\n");
        output.put("==============================\n");

        if (services.length == 0) {
            output.put("No broker services found.\n");
            return output.data;
        }

        foreach (service; services) {
            output.put(format(
                "- %s (%s) region=%s vpn=%s\n",
                service.id.value,
                service.name,
                service.region,
                service.msgVpnName));
        }

        return output.data;
    }
}

final class CliBrokerServiceController {
    private CliBrokerServiceModel model;
    private CliBrokerServiceView view;

    this(CliBrokerServiceModel model, CliBrokerServiceView view) {
        this.model = model;
        this.view = view;
    }

    void list(string tenantId) {
        auto services = model.listServices(tenantId);
        writeln(view.renderList(services));
    }
}
