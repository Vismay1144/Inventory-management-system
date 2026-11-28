using System;
using System.Data;
using System.Web.UI;

namespace StockInventorySystem
{
    public partial class DefaultPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            try
            {
                pnlAlert.Visible = false;

                // 1. Fetch KPI Metrics from MySQL
                DashboardKpiData kpi = ItemRepository.GetDashboardKpis();
                lblTotalItems.Text = kpi.TotalUniqueItems.ToString("#,##0");
                lblTotalQuantity.Text = kpi.TotalStockQuantity.ToString("#,##0");
                lblTotalValue.Text = kpi.TotalInventoryValue.ToString("C2");
                lblLowStockCount.Text = (kpi.LowStockCount + kpi.OutOfStockCount).ToString("#,##0");

                // Banner alert for warehouse staff
                if (kpi.LowStockCount > 0 || kpi.OutOfStockCount > 0)
                {
                    pnlLowStockBanner.Visible = true;
                    lblBannerLowStock.Text = kpi.LowStockCount.ToString();
                    lblBannerOutOfStock.Text = kpi.OutOfStockCount.ToString();
                }
                else
                {
                    pnlLowStockBanner.Visible = false;
                }

                // 2. Fetch Recent Transactions (last 10 movements)
                DataTable dtRecent = TransactionRepository.GetRecentTransactions(10);
                if (dtRecent != null && dtRecent.Rows.Count > 0)
                {
                    rptRecentTransactions.DataSource = dtRecent;
                    rptRecentTransactions.DataBind();
                    rptRecentTransactions.Visible = true;
                    pnlNoTransactions.Visible = false;
                }
                else
                {
                    rptRecentTransactions.Visible = false;
                    pnlNoTransactions.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "<strong>Database Connection Notice:</strong> Unable to load dashboard metrics. " +
                    "Please ensure MySQL is running on localhost:3306 and that InventoryDB has been created via SQLyog. Error: " + Server.HtmlEncode(ex.Message));
            }
        }

        public string GetTransactionTypeBadge(string type)
        {
            switch (type)
            {
                case "Stock In": return "badge-stock-in";
                case "Stock Out": return "badge-stock-out";
                case "Adjustment": return "badge-adjustment";
                default: return "badge-secondary";
            }
        }

        public string GetOrderSourceBadge(string source)
        {
            switch (source)
            {
                case "SAP": return "badge-sap";
                case "E-mail": return "badge-email";
                case "Personal Request": return "badge-request";
                default: return "badge-secondary";
            }
        }

        private void ShowAlert(string type, string htmlMessage)
        {
            pnlAlert.Visible = true;
            pnlAlert.CssClass = "alert alert-" + type;
            litAlertMessage.Text = htmlMessage;
        }
    }
}
