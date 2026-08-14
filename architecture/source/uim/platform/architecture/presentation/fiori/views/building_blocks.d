module uim.platform.architecture.presentation.ui5.views.building_blocks;

import std.array : appender;
import std.format : format;
import std.string : replace;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockUi5View {
    string renderHub(string tenantId) {
        auto tenant = escapeJs(tenantId);
        auto html = appender!string();
        html ~= pageStart("Architecture UI5 Hub");
        html ~= "<script>";
        html ~= "sap.ui.getCore().attachInit(function(){";
        html ~= "var app=new sap.m.App();";
        html ~= "var page=new sap.m.Page({title:'Architecture Building Blocks (UI5)'});";
        html ~= "page.addContent(new sap.m.ObjectStatus({title:'Tenant',text:'" ~ tenant ~ "'}));";
        html ~= "var list=new sap.m.List({inset:true});";
        html ~= navItem("Architecture", "/ui5/architecture/architecture?tenantId=" ~ tenant);
        html ~= navItem("Solution", "/ui5/architecture/solution?tenantId=" ~ tenant);
        html ~= navItem("Data", "/ui5/architecture/data?tenantId=" ~ tenant);
        html ~= navItem("Business", "/ui5/architecture/business?tenantId=" ~ tenant);
        html ~= navItem("Technology", "/ui5/architecture/technology?tenantId=" ~ tenant);
        html ~= "page.addContent(list);app.addPage(page);app.placeAt('content');";
        html ~= "});</script></body></html>";
        return html.data;
    }

    string renderOverview(Ui5BuildingBlockPageModel model) {
        auto html = appender!string();
        auto tenant = escapeJs(model.tenantId);
        html ~= pageStart(model.title);
        html ~= "<script>";
        html ~= "sap.ui.getCore().attachInit(function(){";
        html ~= "var data={title:'" ~ escapeJs(model.title) ~ "',subtitle:'" ~ escapeJs(model.subtitle) ~ "',tenant:'" ~ tenant ~ "',blockType:'" ~ escapeJs(model.blockType) ~ "',items:[";
        foreach (idx, item; model.items) {
            if (idx > 0)
                html ~= ",";
            html ~= "{";
            html ~= "id:'" ~ escapeJs(item.id) ~ "',";
            html ~= "name:'" ~ escapeJs(item.name) ~ "',";
            html ~= "description:'" ~ escapeJs(item.description) ~ "',";
            html ~= "owner:'" ~ escapeJs(item.owner) ~ "',";
            html ~= "status:'" ~ escapeJs(item.status) ~ "',";
            html ~= "lifecycle:'" ~ escapeJs(item.lifecycle) ~ "',";
            html ~= "versionLabel:'" ~ escapeJs(item.versionLabel) ~ "',";
            html ~= "tags:'" ~ escapeJs(item.tags) ~ "'";
            html ~= "}";
        }
        html ~= "]};";
        html ~= "var app=new sap.m.App();";
        html ~= "var page=new sap.m.Page({title:data.title,showNavButton:true,navButtonPress:function(){window.location='/ui5/architecture?tenantId='+encodeURIComponent(data.tenant);}});";
        html ~= "page.addContent(new sap.m.Text({text:data.subtitle}));";
        html ~= "var table=new sap.m.Table({growing:true,columns:[new sap.m.Column({header:new sap.m.Label({text:'ID'})}),new sap.m.Column({header:new sap.m.Label({text:'Name'})}),new sap.m.Column({header:new sap.m.Label({text:'Status'})}),new sap.m.Column({header:new sap.m.Label({text:'Owner'})})]});";
        html ~= "var m=new sap.ui.model.json.JSONModel(data);table.setModel(m);";
        html ~= "table.bindItems('/items',new sap.m.ColumnListItem({type:'Navigation',press:function(e){var c=e.getSource().getBindingContext();var id=c.getProperty('id');window.location='/ui5/architecture/'+data.blockType+'/'+encodeURIComponent(id)+'?tenantId='+encodeURIComponent(data.tenant);},cells:[new sap.m.ObjectIdentifier({title:'{id}'}),new sap.m.Text({text:'{name}'}),new sap.m.ObjectStatus({text:'{status}'}),new sap.m.Text({text:'{owner}'})]}));";
        html ~= "page.addContent(table);app.addPage(page);app.placeAt('content');";
        html ~= "});</script></body></html>";
        return html.data;
    }

    string renderDetail(Ui5BuildingBlockDetailModel model) {
        auto html = appender!string();
        auto tenant = escapeJs(model.tenantId);
        html ~= pageStart(model.title);
        html ~= "<script>";
        html ~= "sap.ui.getCore().attachInit(function(){";
        html ~= "var data={title:'" ~ escapeJs(model.title) ~ "',subtitle:'" ~ escapeJs(model.subtitle) ~ "',tenant:'" ~ tenant ~ "',blockType:'" ~ escapeJs(model.blockType) ~ "',found:" ~ (model.found ? "true" : "false") ~ ",item:{";
        html ~= "id:'" ~ escapeJs(model.item.id) ~ "',";
        html ~= "name:'" ~ escapeJs(model.item.name) ~ "',";
        html ~= "description:'" ~ escapeJs(model.item.description) ~ "',";
        html ~= "owner:'" ~ escapeJs(model.item.owner) ~ "',";
        html ~= "status:'" ~ escapeJs(model.item.status) ~ "',";
        html ~= "lifecycle:'" ~ escapeJs(model.item.lifecycle) ~ "',";
        html ~= "versionLabel:'" ~ escapeJs(model.item.versionLabel) ~ "',";
        html ~= "tags:'" ~ escapeJs(model.item.tags) ~ "'}};";
        html ~= "var app=new sap.m.App();";
        html ~= "var page=new sap.m.Page({title:data.title,showNavButton:true,navButtonPress:function(){window.location='/ui5/architecture/'+data.blockType+'?tenantId='+encodeURIComponent(data.tenant);}});";
        html ~= "if(!data.found){page.addContent(new sap.m.MessageStrip({text:'Building block not found',type:'Warning',showIcon:true}));}";
        html ~= "else{var form=new sap.ui.layout.form.SimpleForm({editable:false,layout:'ResponsiveGridLayout',content:[";
        html ~= field("ID", "id") ~ ",";
        html ~= field("Name", "name") ~ ",";
        html ~= field("Description", "description") ~ ",";
        html ~= field("Owner", "owner") ~ ",";
        html ~= field("Status", "status") ~ ",";
        html ~= field("Lifecycle", "lifecycle") ~ ",";
        html ~= field("Version", "versionLabel") ~ ",";
        html ~= field("Tags", "tags");
        html ~= "]});form.setModel(new sap.ui.model.json.JSONModel(data.item));page.addContent(form);}";
        html ~= "app.addPage(page);app.placeAt('content');";
        html ~= "});</script></body></html>";
        return html.data;
    }

    private string pageStart(string title) {
        return "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>"
            ~ "<title>" ~ escapeHtml(title) ~ "</title>"
            ~ "<script id='sap-ui-bootstrap' src='https://sdk.openui5.org/resources/sap-ui-core.js' data-sap-ui-theme='sap_horizon' data-sap-ui-libs='sap.m,sap.ui.layout' data-sap-ui-compatVersion='edge' data-sap-ui-async='true'></script>"
            ~ "</head><body class='sapUiBody'><div id='content'></div>";
    }

    private string navItem(string title, string href) {
        return "list.addItem(new sap.m.StandardListItem({title:'" ~ escapeJs(title) ~ "',type:'Navigation',press:function(){window.location='" ~ escapeJs(href) ~ "';}}));";
    }

    private string field(string label, string propertyName) {
        return "new sap.m.Label({text:'" ~ escapeJs(label) ~ "'}),new sap.m.Text({text:'{" ~ escapeJs(propertyName) ~ "}'})";
    }

    private string escapeHtml(string value) {
        return value
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private string escapeJs(string value) {
        return value
            .replace("\\", "\\\\")
            .replace("'", "\\'")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("</", "<\\/");
    }
}
