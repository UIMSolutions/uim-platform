/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.presentation.gui.controllers.dashboard;

import std.stdio : writeln;

import uim.platform.identity_directory;
import uim.platform.identity_directory.presentation.gui.models.dashboard;

version (Have_gtkd) {
    import gtk.Application : Application;
}

mixin(ShowModule!());

@safe:

final class IdentityDirectoryGuiController {
    private ManageApiClientsUseCase apiClients;
    private QueryAuditLogUseCase auditLog;
    private ManageUsersUseCase users;
    private ManageGroupsUseCase groups;
    private ManageSchemasUseCase schemas;
    private ManagePasswordPoliciesUseCase passwordPolicies;

    this(ManageApiClientsUseCase apiClients, QueryAuditLogUseCase auditLog,
        ManageUsersUseCase users, ManageGroupsUseCase groups,
        ManageSchemasUseCase schemas, ManagePasswordPoliciesUseCase passwordPolicies) {
        this.apiClients = apiClients;
        this.auditLog = auditLog;
        this.users = users;
        this.groups = groups;
        this.schemas = schemas;
        this.passwordPolicies = passwordPolicies;
    }

    int run(string[] args, TenantId tenantId) {
        version (Have_gtkd) {
            import gio.ApplicationFlags;
            import gtk.Application : Application;
            import uim.platform.identity_directory.presentation.gui.views.dashboard : IdentityDirectoryGuiWindow;

            auto app = new Application("org.uim.identity-directory.gui", ApplicationFlags.FLAGS_NONE);
            app.addOnActivate((_) { onActivate(app, tenantId); });
            return app.run(args);
        }
        else {
            auto dashboard = buildDashboardModel(tenantId.value,
                apiClients.listClients(tenantId).length,
                auditLog.listEvents(tenantId).length,
                users.listUsers(tenantId).length,
                groups.listGroups(tenantId).length,
                schemas.listSchemas(tenantId).length,
                passwordPolicies.listPolicies(tenantId).length);
            writeln(renderTextReport(dashboard, buildPages(tenantId)));
            return 0;
        }
    }

    private void onActivate(Application app, TenantId tenantId) {
        import uim.platform.identity_directory.presentation.gui.views.dashboard : IdentityDirectoryGuiWindow;

        auto dashboard = buildDashboardModel(tenantId.value,
            apiClients.listClients(tenantId).length,
            auditLog.listEvents(tenantId).length,
            users.listUsers(tenantId).length,
            groups.listGroups(tenantId).length,
            schemas.listSchemas(tenantId).length,
            passwordPolicies.listPolicies(tenantId).length);
        auto window = new IdentityDirectoryGuiWindow(app, dashboard, buildPages(tenantId));
        window.present();
    }

    private GuiPageModel[] buildPages(TenantId tenantId) {
        return [
            buildApiClientsModel(tenantId.value, apiClients.listClients(tenantId)),
            buildAuditModel(tenantId.value, auditLog.listEvents(tenantId)),
            buildUsersModel(tenantId.value, users.listUsers(tenantId)),
            buildGroupsModel(tenantId.value, groups.listGroups(tenantId)),
            buildSchemasModel(tenantId.value, schemas.listSchemas(tenantId)),
            buildPasswordPoliciesModel(tenantId.value, passwordPolicies.listPolicies(tenantId)),
        ];
    }
}
