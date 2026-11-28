<%@ Page Title="Item Master" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="ItemMaster.aspx.cs" Inherits="StockInventorySystem.ItemMasterPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Page Header -->
    <div class="page-header">
        <div class="page-title">
            <h2>Item Master Management</h2>
            <p>Register new inventory parts, update item catalogs, and manage warehouse storage bin locations.</p>
        </div>
    </div>

    <!-- Alert Banner -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert">
        <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Item Entry / Edit Form Card -->
    <div class="content-card">
        <div class="card-header">
            <h3><asp:Label ID="lblFormTitle" runat="server" Text="➕ Register New Inventory Item"></asp:Label></h3>
            <asp:HiddenField ID="hdnIsEditMode" runat="server" Value="0" />
        </div>
        <div class="card-body">
            <div class="form-grid">
                <!-- Part Number (Unique) -->
                <div class="form-group">
                    <label class="form-label" for="txtPartNo">
                        Part Number (SKU / Code) <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtPartNo" runat="server" CssClass="form-control" MaxLength="50" placeholder="e.g. P-1011 or SKU-9002"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Unique primary key. Duplicates are blocked.</span>
                </div>

                <!-- Item Name -->
                <div class="form-group">
                    <label class="form-label" for="txtItemName">
                        Item Name &amp; Description <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control" MaxLength="150" placeholder="e.g. Cat6 Patch Cable 5m"></asp:TextBox>
                </div>

                <!-- Unit Price -->
                <div class="form-group">
                    <label class="form-label" for="txtUnitPrice">
                        Unit Price ($ USD) <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control" TextMode="Number" step="0.01" min="0" placeholder="0.00"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Must be greater than or equal to $0.00</span>
                </div>

                <!-- Location -->
                <div class="form-group">
                    <label class="form-label" for="txtLocation">
                        Storage Location <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. Warehouse A - Rack 02 - Shelf 1"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Warehouse, rack, shelf, or bin coordinate</span>
                </div>

                <!-- Opening Quantity (only editable when creating new item) -->
                <div class="form-group" id="divOpeningQty" runat="server">
                    <label class="form-label" for="txtCurrentQuantity">
                        Opening Stock Quantity <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtCurrentQuantity" runat="server" CssClass="form-control" TextMode="Number" min="0" Text="0"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Subsequent updates are tracked via Transaction Master.</span>
                </div>
            </div>

            <div class="form-actions">
                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-primary" Text="💾 Save Item" OnClick="btnSave_Click" />
                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary" Text="Clear / Reset Form" OnClick="btnCancel_Click" CausesValidation="false" />
            </div>
        </div>
    </div>

    <!-- Search & Filter Bar -->
    <div class="filter-bar">
        <div class="filter-grid" style="grid-template-columns: 1fr auto auto;">
            <div class="form-group">
                <label class="form-label" for="txtSearch">Live Search (Part Number, Item Name, or Location)</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control table-quick-search" data-target-table="tblItemMaster" placeholder="Type to filter items instantly..."></asp:TextBox>
            </div>
            <div class="form-group">
                <label class="form-label">&nbsp;</label>
                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-secondary" Text="🔍 Search (Server)" OnClick="btnSearch_Click" />
            </div>
            <div class="form-group">
                <label class="form-label">&nbsp;</label>
                <asp:Button ID="btnResetSearch" runat="server" CssClass="btn btn-outline" Text="Reset" OnClick="btnResetSearch_Click" />
            </div>
        </div>
    </div>

    <!-- Items Grid Table -->
    <div class="content-card">
        <div class="card-header">
            <h3>Registered Items in Catalog (<asp:Label ID="lblItemCount" runat="server" Text="0"></asp:Label>)</h3>
            <span style="font-size: 0.8rem; color: var(--text-muted);">Reorder alert threshold: &lt; 10 units</span>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
                    <HeaderTemplate>
                        <table class="data-table" id="tblItemMaster">
                            <thead>
                                <tr>
                                    <th>Part No</th>
                                    <th>Item Name</th>
                                    <th>Storage Location</th>
                                    <th style="text-align: right;">Unit Price</th>
                                    <th style="text-align: right;">Current Stock</th>
                                    <th style="text-align: center;">Stock Status</th>
                                    <th style="text-align: center;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><code><%# Eval("PartNo") %></code></td>
                            <td><strong><%# Eval("ItemName") %></strong></td>
                            <td><span style="color: var(--secondary);"><%# Eval("Location") %></span></td>
                            <td style="text-align: right; font-weight: 600;">
                                <%# Eval("UnitPrice", "{0:C2}") %>
                            </td>
                            <td style="text-align: right; font-weight: 700; font-size: 1rem;">
                                <%# Eval("CurrentQuantity") %>
                            </td>
                            <td style="text-align: center;">
                                <span class='badge <%# GetStockStatusBadge(Eval("StockStatus").ToString()) %>'>
                                    <%# Eval("StockStatus") %>
                                </span>
                            </td>
                            <td style="text-align: center;">
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-secondary btn-sm"
                                    CommandName="EditItem" CommandArgument='<%# Eval("PartNo") %>' CausesValidation="false">
                                    ✏️ Edit
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoItems" runat="server" Visible="false" CssClass="table-empty">
                    <p>No inventory items found matching your search. Create your first item above.</p>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
