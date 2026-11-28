using System;
using System.Data;
using System.Web.UI;

namespace StockInventorySystem
{
    public partial class TransactionDetailsPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Default From/To: Last 30 days
                txtFromDate.Text = DateTime.Now.AddDays(-30).ToString("yyyy-MM-dd");
                txtToDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

                BindTransactions();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;

            // Validate date range
            if (!string.IsNullOrWhiteSpace(txtFromDate.Text) && !string.IsNullOrWhiteSpace(txtToDate.Text))
            {
                DateTime fromDate, toDate;
                if (DateTime.TryParse(txtFromDate.Text, out fromDate) && DateTime.TryParse(txtToDate.Text, out toDate))
                {
                    if (toDate < fromDate)
                    {
                        ShowAlert("danger", "<strong>Validation Error:</strong> 'To Date' cannot be earlier than 'From Date'. Please correct the date range.");
                        return;
                    }
                }
            }

            BindTransactions();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            txtFromDate.Text = "";
            txtToDate.Text = "";
            txtSearch.Text = "";
            ddlFilterOrderSource.SelectedIndex = 0;
            ddlFilterType.SelectedIndex = 0;

            BindTransactions();
        }

        protected void btnExportCsv_Click(object sender, EventArgs e)
        {
            try
            {
                DataTable dt = GetFilteredData();
                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowAlert("warning", "No records found matching current criteria to export.");
                    return;
                }

                string csvData = TransactionRepository.GenerateCsv(dt);
                string filename = string.Format("Stock_Transactions_{0}.csv", DateTime.Now.ToString("yyyyMMdd_HHmmss"));

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=" + filename);
                Response.Charset = "utf-8";
                Response.ContentType = "text/csv; charset=utf-8";

                // Write UTF-8 BOM for Microsoft Excel compatibility
                byte[] preamble = System.Text.Encoding.UTF8.GetPreamble();
                Response.BinaryWrite(preamble);

                byte[] data = System.Text.Encoding.UTF8.GetBytes(csvData);
                Response.BinaryWrite(data);
                Response.Flush();
                Response.SuppressContent = true;
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Could not export CSV: " + Server.HtmlEncode(ex.Message));
            }
        }

        private DataTable GetFilteredData()
        {
            DateTime? fromDate = null;
            DateTime? toDate = null;

            DateTime parsedFrom;
            if (DateTime.TryParse(txtFromDate.Text, out parsedFrom))
            {
                fromDate = parsedFrom;
            }

            DateTime parsedTo;
            if (DateTime.TryParse(txtToDate.Text, out parsedTo))
            {
                toDate = parsedTo;
            }

            string searchKeyword = txtSearch.Text.Trim();
            string orderSource = ddlFilterOrderSource.SelectedValue;
            string transactionType = ddlFilterType.SelectedValue;

            return TransactionRepository.GetFilteredTransactions(fromDate, toDate, searchKeyword, orderSource, transactionType);
        }

        private void BindTransactions()
        {
            try
            {
                DataTable dt = GetFilteredData();
                if (dt != null && dt.Rows.Count > 0)
                {
                    rptTransactions.DataSource = dt;
                    rptTransactions.DataBind();
                    rptTransactions.Visible = true;
                    pnlNoTransactions.Visible = false;
                    lblRecordCount.Text = dt.Rows.Count.ToString("#,##0");
                }
                else
                {
                    rptTransactions.DataSource = null;
                    rptTransactions.DataBind();
                    rptTransactions.Visible = false;
                    pnlNoTransactions.Visible = true;
                    lblRecordCount.Text = "0";
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "<strong>Database Error:</strong> " + Server.HtmlEncode(ex.Message));
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
