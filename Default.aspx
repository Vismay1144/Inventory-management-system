<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="StockInventorySystem.DefaultPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Page Header -->
    <div class="page-header">
        <div class="page-title">
            <h2>Inventory Dashboard &amp; Navigation Hub</h2>
            <p>Real-time KPI summary, quick access modules, and recent stock movements.</p>
        </div>
        <div>
            <asp:LinkButton ID="btnRefresh" runat="server" CssClass="btn btn-secondary btn-sm" OnClick="btnRefresh_Click">
                🔄 Refresh Dashboard
            </asp:LinkButton>
        </div>
    </div>

    <!-- Alert / Message placeholder -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert">
        <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Low Stock Alert Banner (conditionally displayed if low or out-of-stock items exist) -->
    <asp:Panel ID="pnlLowStockBanner" runat="server" Visible="false" CssClass="alert alert-warning">
        <span>⚠️</span>
        <div>
            <strong>Attention Required:</strong> You have 
            <asp:Label ID="lblBannerLowStock" runat="server" Font-Bold="true"></asp:Label> item(s) below reorder threshold (&lt;10 units) and 
            <asp:Label ID="lblBannerOutOfStock" runat="server" Font-Bold="true"></asp:Label> item(s) completely out of stock. 
            <a href="TransactionMaster.aspx" style="color: var(--primary); font-weight: 700; text-decoration: underline; margin-left: 0.5rem;">Create Stock In Transaction &rarr;</a>
        </div>
    </asp:Panel>

    <!-- KPI Summary Cards Grid -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-info">
                <h4>Total Unique Items</h4>
                <div class="kpi-value"><asp:Label ID="lblTotalItems" runat="server">0</asp:Label></div>
                <div class="kpi-subtext">Active SKUs in Item Master</div>
            </div>
            <div class="kpi-icon blue">📁</div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <h4>Total Stock Quantity</h4>
                <div class="kpi-value"><asp:Label ID="lblTotalQuantity" runat="server">0</asp:Label></div>
                <div class="kpi-subtext">Total physical units in stock</div>
            </div>
            <div class="kpi-icon green">📦</div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <h4>Total Inventory Value</h4>
                <div class="kpi-value"><asp:Label ID="lblTotalValue" runat="server">$0.00</asp:Label></div>
                <div class="kpi-subtext">Calculated as &Sigma;(UnitPrice &times; Qty)</div>
            </div>
            <div class="kpi-icon purple">💲</div>
        </div>

        <div class="kpi-card">
            <div class="kpi-info">
                <h4>Low Stock Alerts</h4>
                <div class="kpi-value" style="color: var(--danger);"><asp:Label ID="lblLowStockCount" runat="server">0</asp:Label></div>
                <div class="kpi-subtext">Items with quantity &lt; 10 units</div>
            </div>
            <div class="kpi-icon amber">⚠️</div>
        </div>
    </div>

    <!-- Quick-Access Cards to Switch Seamlessly Between Modules -->
    <div class="action-cards-grid">
        <a href="Default.aspx" class="action-card" style="border-top-color: var(--accent);">
            <div class="action-card-header">
                <span style="font-size: 1.5rem;">📊</span>
                <h3>1. Main Dashboard</h3>
            </div>
            <div class="action-card-body">
                <p>Central overview with real-time stock KPIs, inventory health alerts, and instant recent movement audit log.</p>
            </div>
            <div class="action-card-footer">
                <span>Current View</span>
                <span>&bull; Active</span>
            </div>
        </a>

        <a href="ItemMaster.aspx" class="action-card" style="border-top-color: #2563eb;">
            <div class="action-card-header">
                <span style="font-size: 1.5rem;">📑</span>
                <h3>2. Item Master</h3>
            </div>
            <div class="action-card-body">
                <p>Register new inventory parts, block duplicate Part Numbers, manage storage bins/locations, and update unit prices.</p>
            </div>
            <div class="action-card-footer">
                <span>Manage Items</span>
                <span>Open Tab &rarr;</span>
            </div>
        </a>

        <a href="TransactionMaster.aspx" class="action-card" style="border-top-color: #10b981;">
            <div class="action-card-header">
                <span style="font-size: 1.5rem;">⚡</span>
                <h3>3. Transaction Master</h3>
            </div>
            <div class="action-card-body">
                <p>Record Stock In, Stock Out, or Adjustments via SAP, E-mail, or Personal Requests with live overdraft protection.</p>
            </div>
            <div class="action-card-footer">
                <span>Post Movements</span>
                <span>Open Tab &rarr;</span>
            </div>
        </a>

        <a href="TransactionDetails.aspx" class="action-card" style="border-top-color: #8b5cf6;">
            <div class="action-card-header">
                <span style="font-size: 1.5rem;">🔍</span>
                <h3>4. Transaction Details</h3>
            </div>
            <div class="action-card-body">
                <p>Historical audit trails with From/To date range filtering, Order Source search, and one-click offline CSV/Excel export.</p>
            </div>
            <div class="action-card-footer">
                <span>Audit &amp; Export</span>
                <span>Open Tab &rarr;</span>
            </div>
        </a>
    </div>

    <!-- Recent Transactions Table Card -->
    <div class="content-card">
        <div class="card-header">
            <h3>Recent Stock Movements (Latest 10 Transactions)</h3>
            <a href="TransactionDetails.aspx" class="btn btn-outline btn-sm">View Full Historical Audit Log &rarr;</a>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <asp:Repeater ID="rptRecentTransactions" runat="server">
                    <HeaderTemplate>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Date &amp; Time</th>
                                    <th>Part No</th>
                                    <th>Item Name</th>
                                    <th>Movement Type</th>
                                    <th style="text-align: right;">Quantity</th>
                                    <th>Order Source</th>
                                    <th style="text-align: right;">Balance After</th>
                                    <th>Reference / Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><strong>#<%# Eval("TransactionID") %></strong></td>
                            <td><%# Eval("TransactionDate", "{0:yyyy-MM-dd HH:mm}") %></td>
                            <td><code><%# Eval("PartNo") %></code></td>
                            <td><strong><%# Eval("ItemName") %></strong></td>
                            <td>
                                <span class='badge <%# GetTransactionTypeBadge(Eval("TransactionType").ToString()) %>'>
                                    <%# Eval("TransactionType") %>
                                </span>
                            </td>
                            <td style="text-align: right; font-weight: 700;">
                                <%# Eval("Quantity") %>
                            </td>
                            <td>
                                <span class='badge <%# GetOrderSourceBadge(Eval("OrderSource").ToString()) %>'>
                                    <%# Eval("OrderSource") %>
                                </span>
                            </td>
                            <td style="text-align: right; font-weight: 600;">
                                <%# Eval("BalanceAfterTransaction") %>
                            </td>
                            <td><span style="color: var(--text-muted);"><%# Eval("ReferenceRemarks") %></span></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoTransactions" runat="server" Visible="false" CssClass="table-empty">
                    <p>No transactions found in database. Use <strong>Transaction Master</strong> to record movements.</p>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
