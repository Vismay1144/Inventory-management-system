using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StockInventorySystem
{
    public partial class TransactionMasterPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtTransactionDate.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");
                PopulateItemsDropdown();
                BindActiveStockTracker();
            }
        }

        private void PopulateItemsDropdown()
        {
            try
            {
                ddlPartNo.Items.Clear();
                ddlPartNo.Items.Add(new ListItem("-- Select Part Number / Item --", ""));

                DataTable dt = ItemRepository.GetItemsForDropdown();
                foreach (DataRow row in dt.Rows)
                {
                    string partNo = row["PartNo"].ToString();
                    string itemName = row["ItemName"].ToString();
                    int qty = Convert.ToInt32(row["CurrentQuantity"]);
                    decimal price = Convert.ToDecimal(row["UnitPrice"]);
                    string location = row["Location"].ToString();

                    string displayText = string.Format("{0} - {1} (Available: {2})", partNo, itemName, qty);
                    var item = new ListItem(displayText, partNo);
                    item.Attributes.Add("data-location", location);
                    item.Attributes.Add("data-qty", qty.ToString());
                    item.Attributes.Add("data-price", price.ToString("F2"));

                    ddlPartNo.Items.Add(item);
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Could not load item catalog: " + Server.HtmlEncode(ex.Message));
            }
        }

        private void BindActiveStockTracker(string searchKeyword = null)
        {
            try
            {
                DataTable dt = ItemRepository.GetActiveStockTracker(searchKeyword);
                if (dt != null && dt.Rows.Count > 0)
                {
                    rptActiveStock.DataSource = dt;
                    rptActiveStock.DataBind();
                    rptActiveStock.Visible = true;
                    pnlNoActiveStock.Visible = false;
                }
                else
                {
                    rptActiveStock.DataSource = null;
                    rptActiveStock.DataBind();
                    rptActiveStock.Visible = false;
                    pnlNoActiveStock.Visible = true;
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Could not load active stock tracker: " + Server.HtmlEncode(ex.Message));
            }
        }

        protected void btnSubmitTransaction_Click(object sender, EventArgs e)
        {
            try
            {
                pnlAlert.Visible = false;

                string partNo = ddlPartNo.SelectedValue;
                if (string.IsNullOrWhiteSpace(partNo))
                {
                    ShowAlert("warning", "Please select an inventory item from the dropdown.");
                    ddlPartNo.Focus();
                    return;
                }

                DateTime transDate;
                if (!DateTime.TryParse(txtTransactionDate.Text, out transDate))
                {
                    transDate = DateTime.Now;
                }

                int qty;
                if (!int.TryParse(txtQuantity.Text.Trim(), out qty) || qty <= 0)
                {
                    ShowAlert("warning", "Quantity must be a positive whole integer greater than zero.");
                    txtQuantity.Focus();
                    return;
                }

                string transType = ddlTransactionType.SelectedValue;
                string orderSource = ddlOrderSource.SelectedValue;
                string remarks = txtRemarks.Text.Trim();
                string adjustDir = ddlAdjustmentDirection.SelectedValue;

                // Execute atomic transaction with MySQL row lock
                int newTransId = TransactionRepository.RecordTransaction(
                    partNo, 
                    transDate, 
                    transType, 
                    qty, 
                    orderSource, 
                    remarks, 
                    adjustDir
                );

                ShowAlert("success", string.Format(
                    "<strong>Transaction #{0} Posted Successfully:</strong> Recorded <strong>{1}</strong> of {2} unit(s) for Part <strong>{3}</strong> via <strong>{4}</strong>. Stock balances updated synchronously.",
                    newTransId, transType, qty, Server.HtmlEncode(partNo), Server.HtmlEncode(orderSource)));

                // Reset inputs
                txtQuantity.Text = "1";
                txtRemarks.Text = "";
                txtTransactionDate.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");

                // Refresh dropdown and active stock tracker
                PopulateItemsDropdown();
                ddlPartNo.SelectedValue = partNo; // Keep selected to see new balance
                BindActiveStockTracker();
            }
            catch (InsufficientStockException isEx)
            {
                ShowAlert("danger", "<strong>Transaction Blocked:</strong> " + Server.HtmlEncode(isEx.Message));
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "<strong>Transaction Failed:</strong> " + Server.HtmlEncode(ex.Message));
            }
        }

        protected void btnResetForm_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            ddlPartNo.SelectedIndex = 0;
            ddlTransactionType.SelectedIndex = 0;
            ddlOrderSource.SelectedIndex = 0;
            txtQuantity.Text = "1";
            txtRemarks.Text = "";
            txtTransactionDate.Text = DateTime.Now.ToString("yyyy-MM-ddTHH:mm");
        }

        protected void btnRefreshTracker_Click(object sender, EventArgs e)
        {
            BindActiveStockTracker();
        }

        public string GetStockStatusBadge(string status)
        {
            switch (status)
            {
                case "In Stock": return "badge-in-stock";
                case "Low Stock": return "badge-low-stock";
                case "Out of Stock": return "badge-out-of-stock";
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
