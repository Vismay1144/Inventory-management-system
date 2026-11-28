<%@ Page Title="Transaction Details & Date Range Search" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="TransactionDetails.aspx.cs" Inherits="StockInventorySystem.TransactionDetailsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Page Header -->
    <div class="page-header">
        <div class="page-title">
            <h2>Transaction Details &amp; Historical Audit Log</h2>
            <p>Search, filter, and audit all inventory movements across customizable date ranges, order sources, and movement types.</p>
        </div>
        <div>
            <asp:LinkButton ID="btnExportCsv" runat="server" CssClass="btn btn-success" OnClick="btnExportCsv_Click">
                📥 Export to CSV / Excel
            </asp:LinkButton>
        </div>
    </div>

    <!-- Alert / Validation Banner -->
    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert">
        <asp:Literal ID="litAlertMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Filter & Date Range Search Bar -->
    <div class="filter-bar">
        <div class="filter-grid" style="grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));">
            <!-- From Date -->
            <div class="form-group">
                <label class="form-label" for="txtFromDate">From Date</label>
                <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
            </div>

            <!-- To Date -->
            <div class="form-group">
                <label class="form-label" for="txtToDate">To Date</label>
                <asp:TextBox ID="txtToDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
            </div>

            <!-- Part No / Item Name / Location Search -->
            <div class="form-group">
                <label class="form-label" for="txtSearch">Part No. / Item / Location</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search keyword..."></asp:TextBox>
            </div>

            <!-- Order Source Filter -->
            <div class="form-group">
                <label class="form-label" for="ddlFilterOrderSource">Order Source</label>
                <asp:DropDownList ID="ddlFilterOrderSource" runat="server" CssClass="form-control">
                    <asp:ListItem Text="-- All Order Sources --" Value="All"></asp:ListItem>
                    <asp:ListItem Text="SAP" Value="SAP"></asp:ListItem>
                    <asp:ListItem Text="E-mail" Value="E-mail"></asp:ListItem>
                    <asp:ListItem Text="Personal Request" Value="Personal Request"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- Transaction Type Filter -->
            <div class="form-group">
                <label class="form-label" for="ddlFilterType">Transaction Type</label>
                <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="form-control">
                    <asp:ListItem Text="-- All Movement Types --" Value="All"></asp:ListItem>
                    <asp:ListItem Text="Stock In" Value="Stock In"></asp:ListItem>
                    <asp:ListItem Text="Stock Out" Value="Stock Out"></asp:ListItem>
                    <asp:ListItem Text="Adjustment" Value="Adjustment"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <!-- Action Buttons -->
            <div class="form-group" style="display: flex; gap: 0.5rem; flex-direction: row; align-items: flex-end;">
                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary" Text="🔍 Search" OnClick="btnSearch_Click" ClientIDMode="Static" />
                <asp:Button ID="btnReset" runat="server" CssClass="btn btn-outline" Text="Reset" OnClick="btnReset_Click" />
            </div>
        </div>
    </div>

    <!-- Historical Transactions Grid Table -->
    <div class="content-card">
        <div class="card-header">
            <h3>Historical Audit Log (<asp:Label ID="lblRecordCount" runat="server" Text="0"></asp:Label> Records Found)</h3>
            <span style="font-size: 0.8rem; color: var(--text-muted);">Immutable audit trail recorded via ADO.NET</span>
        </div>
        <div class="card-body" style="padding: 0;">
            <div class="table-responsive">
                <asp:Repeater ID="rptTransactions" runat="server">
                    <HeaderTemplate>
                        <table class="data-table" id="tblTransactionAudit">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Date &amp; Time</th>
                                    <th>Part No</th>
                                    <th>Item Name</th>
                                    <th>Storage Location</th>
                                    <th>Type</th>
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
                            <td style="white-space: nowrap;"><%# Eval("TransactionDate", "{0:yyyy-MM-dd HH:mm}") %></td>
                            <td><code><%# Eval("PartNo") %></code></td>
                            <td><strong><%# Eval("ItemName") %></strong></td>
                            <td><span style="color: var(--secondary);"><%# Eval("Location") %></span></td>
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
                            <td>
                                <span style="color: var(--text-muted);"><%# Eval("ReferenceRemarks") %></span>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoTransactions" runat="server" Visible="false" CssClass="table-empty">
                    <p>No historical transactions match your date range or filter criteria.</p>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
</asp:Content>
