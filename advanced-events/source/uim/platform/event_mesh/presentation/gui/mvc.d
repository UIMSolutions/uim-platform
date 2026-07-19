/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.gui.mvc;

import std.array : appender;
import std.stdio : writeln;

import uim.platform.event_mesh;
mixin(ShowModule!());

@safe:

final class GuiBrokerServiceModel {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    BrokerService[] listServices(string tenantId) {
        return usecase.listServices(TenantId(tenantId));
    }
}

final class GuiBrokerServiceView {
    string renderText(BrokerService[] services) const {
        auto text = appender!string();

        if (services.length == 0) {
            text.put("No broker services found.\n");
            return text.data;
        }

        foreach (service; services) {
            text.put(service.name.length > 0 ? service.name : service.id.value);
            text.put("\n");
        }

        return text.data;
    }

    void showWithGtkD(string content) {
        version (GtkD) {
            import gtk.Main;
            import gtk.MainWindow;
            import gtk.ScrolledWindow;
            import gtk.TextView;

            Main.init([]);

            auto window = new MainWindow("Event Mesh Broker Services");
            window.setDefaultSize(900, 600);
            window.addOnDestroy(&Main.quit);

            auto scrolled = new ScrolledWindow();
            auto textView = new TextView();
            textView.setEditable(false);
            textView.getBuffer().setText(content);
            scrolled.add(textView);

            window.add(scrolled);
            window.showAll();
            Main.run();
        }
        else {
            // gtk-d support is optional; fallback keeps the MVC surface usable without GUI dependencies.
            writeln(content);
        }
    }
}

final class GuiBrokerServiceController {
    private GuiBrokerServiceModel model;
    private GuiBrokerServiceView view;

    this(GuiBrokerServiceModel model, GuiBrokerServiceView view) {
        this.model = model;
        this.view = view;
    }

    void show(string tenantId) {
        auto services = model.listServices(tenantId);
        auto content = view.renderText(services);
        view.showWithGtkD(content);
    }
}
