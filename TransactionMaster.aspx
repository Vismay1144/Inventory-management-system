<%@ Page Title="Transaction Master & Active Stock Tracking" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="TransactionMaster.aspx.cs" Inherits="StockInventorySystem.TransactionMasterPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Page Header -->
    <div class="page-header">
        <div class="page-title">
            <h2>Transaction Master &amp; Active Stock Tracking</h2>
            <p>Post atomic inventory stock movements (SAP, E-mail, Personal Requests) and monitor real-time stock levels.</p>
        </div>
    </div>

    <!-- Alert / Validation Banner -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert">
        <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Client-side Overdraft Warning Box -->
    <div id="stockOutWarning" class="alert alert-danger" style="display: none; font-weight: 600;">
        ⚠️ Warning: Requested Stock Out exceeds currently available stock!
    </div>

    <!-- Transaction Entry Form Card -->
    <div class="content-card">
        <div class="card-header">
            <h3>⚡ Record Stock Movement Transaction</h3>
            <span style="font-size: 0.8rem; color: var(--text-muted);">Atomic MySQL Transaction &bull; Live Overdraft Protection</span>
        </div>
        <div class="card-body">
            <div class="form-grid">
                <!-- Transaction Date & Time -->
                <div class="form-group">
                    <label class="form-label" for="txtTransactionDate">
                        Transaction Date &amp; Time <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtTransactionDate" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Defaulted to current intranet server time</span>
                </div>

                <!-- Part Number & Item Selection (Synced with Item Master) -->
                <div class="form-group">
                    <label class="form-label" for="ddlPartNo">
                        Select Part / Item <span class="required">*</span>
                    </label>
                    <asp:DropDownList ID="ddlPartNo" runat="server" CssClass="form-control" ClientIDMode="Static">
                    </asp:DropDownList>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Auto-fills current location and available balance below</span>
                </div>

                <!-- Transaction Type -->
                <div class="form-group">
                    <label class="form-label" for="ddlTransactionType">
                        Transaction Type <span class="required">*</span>
                    </label>
                    <asp:DropDownList ID="ddlTransactionType" runat="server" CssClass="form-control" ClientIDMode="Static">
                        <asp:ListItem Text="Stock In (Receipt / Replenishment)" Value="Stock In"></asp:ListItem>
                        <asp:ListItem Text="Stock Out (Issue / Consumption)" Value="Stock Out"></asp:ListItem>
                        <asp:ListItem Text="Adjustment (Physical Audit Discrepancy)" Value="Adjustment"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <!-- Quantity -->
                <div class="form-group">
                    <label class="form-label" for="txtQuantity">
                        Movement Quantity <span class="required">*</span>
                    </label>
                    <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control" TextMode="Number" min="1" Text="1" ClientIDMode="Static"></asp:TextBox>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Must be a positive whole integer (> 0)</span>
                </div>

                <!-- Order Source (Exact specified values: SAP, E-mail, Personal Request) -->
                <div class="form-group">
                    <label class="form-label" for="ddlOrderSource">
                        Order Source <span class="required">*</span>
                    </label>
                    <asp:DropDownList ID="ddlOrderSource" runat="server" CssClass="form-control">
                        <asp:ListItem Text="SAP (Enterprise PO / Transfer)" Value="SAP"></asp:ListItem>
                        <asp:ListItem Text="E-mail (Department Authorization)" Value="E-mail"></asp:ListItem>
                        <asp:ListItem Text="Personal Request (Direct Staff Voucher)" Value="Personal Request"></asp:ListItem>
                    </asp:DropDownList>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Official origin channel of the request</span>
                </div>

                <!-- Adjustment Mode (only active when Adjustment is selected) -->
                <div class="form-group" id="divAdjustmentDirection">
                    <label class="form-label" for="ddlAdjustmentDirection">
                        Adjustment Direction (Audit Count)
                    </label>
                    <asp:DropDownList ID="ddlAdjustmentDirection" runat="server" CssClass="form-control">
                        <asp:ListItem Text="Deduct (-) Lost / Damaged / Write-off" Value="Deduct"></asp:ListItem>
                        <asp:ListItem Text="Add (+) Found Stock / Surplus Reconciliation" Value="Add"></asp:ListItem>
                    </asp:DropDownList>
                    <span style="font-size: 0.75rem; color: var(--text-light);">Applies only when Transaction Type = Adjustment</span>
                </div>

                <!-- Reference / Remarks -->
                <div class="form-group span-full">
                    <label class="form-label" for="txtRemarks">
                        Reference / Remarks (Optional)
                    </label>
                    <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" MaxLength="255" placeholder="e.g., SAP PO# 4500981999, Email from Ops Lead, or Requesting Employee Name / Badge #"></asp:TextBox>
                </div>
            </div>

            <!-- Live Item Preview Card (Auto-filled on Item Selection via JavaScript) -->
            <div class="item-preview-box" id="itemPreviewBox">
                <div class="preview-stat">
                    <span class="preview-stat-label">STORAGE LOCATION</span>
                    <span class="preview-stat-val" id="lblSelectedLocation">-- Select Item --</span>
                </div>
                <div class="preview-stat">
                    <span class="preview-stat-label">CURRENT AVAILABLE BALANCE</span>
                    <span class="preview-stat-val" id="lblSelectedQty" style="color: var(--primary);">--</span>
                </div>
                <div class="preview-stat">
                    <span class="preview-stat-label">UNIT COST</span>
                    <span class="preview-stat-val" id="lblSelectedPrice">--</span>
                </div>
                <div class="preview-stat">
                    <span class="preview-stat-label">SYSTEM TRANSACTION ID</span>
                    <span class="preview-stat-val" style="color: var(--text-muted); font-size: 0.95rem;">Auto-assigned by MySQL</span>
                </div>
            </div>

            <asp:HiddenField ID="hdnAvailableQty" runat="server" Value="0" ClientIDMode="Static" />

            <div class="form-actions">
                <asp:Button ID="btnSubmitTransaction" runat="server" CssClass="btn btn-primary" Text="⚡ Post Transaction to Ledger" OnClick="btnSubmitTransaction_Click" />
                <asp:Button ID="btnResetForm" runat="server" CssClass="btn btn-secondary" Text="Reset Form" OnClick="btnResetForm_Click" CausesValidation="false" />
            </div>
        </div>
    </div>

    <!-- Active Stock Tracker Section -->
    <div class="content-card">
        <div class="card-header">
            <h3>Active Stock Tracker (Live Inventory Levels &amp; Last Movement)</h3>
            <div style="display: flex; gap: 0.5rem; align-items: center;">
                <input type="text" class="form-control table-quick-search" data-target-table="tblActiveTracker" placeholder="Filter active tracker..." style="width: 220px; padding: 0.4rem 0.6rem; font-size: 0.8rem;" />
                <asp:LinkButton ID="btnRefreshTracker" runat="server" CssClass="btn btn-secondary btn-sm" OnClick="btnRefreshTracker_Click">
                    🔄 Refresh
                </asp:LinkButton>
            </div>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <asp:Repeater ID="rptActiveStock" runat="server">
                    <HeaderTemplate>
                        <table class="data-table" id="tblActiveTracker">
                            <thead>
                                <tr>
                                    <th>Part No</th>
                                    <th>Item Name</th>
                                    <th>Location</th>
                                    <th style="text-align: right;">Unit Price</th>
                                    <th style="text-align: right;">Available Quantity</th>
                                    <th style="text-align: center;">Stock Status</th>
                                    <th>Last Transaction Date</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><code><%# Eval("PartNo") %></code></td>
                            <td><strong><%# Eval("ItemName") %></strong></td>
                            <td><span style="color: var(--secondary);"><%# Eval("Location") %></span></td>
                            <td style="text-align: right;"><%# Eval("UnitPrice", "{0:C2}") %></td>
                            <td style="text-align: right; font-weight: 800; font-size: 1rem;">
                                <%# Eval("CurrentQuantity") %>
                            </td>
                            <td style="text-align: center;">
                                <span class='badge <%# GetStockStatusBadge(Eval("StockStatus").ToString()) %>'>
                                    <%# Eval("StockStatus") %>
                                </span>
                            </td>
                            <td>
                                <%# Eval("LastTransactionDate") != DBNull.Value ? Convert.ToDateTime(Eval("LastTransactionDate")).ToString("yyyy-MM-dd HH:mm") : "<span style='color: var(--text-light);'>No transactions yet</span>" %>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoActiveStock" runat="server" Visible="false" CssClass="table-empty">
                    <p>No inventory items found. Add items in <strong>Item Master</strong> first.</p>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
