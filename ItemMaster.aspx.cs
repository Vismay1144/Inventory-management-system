using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StockInventorySystem
{
    public partial class ItemMasterPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindItemList();
            }
        }

        private void BindItemList(string searchKeyword = null)
        {
            try
            {
                DataTable dt = ItemRepository.GetAllItems(searchKeyword);
                if (dt != null && dt.Rows.Count > 0)
                {
                    rptItems.DataSource = dt;
                    rptItems.DataBind();
                    rptItems.Visible = true;
                    pnlNoItems.Visible = false;
                    lblItemCount.Text = dt.Rows.Count.ToString();
                }
                else
                {
                    rptItems.Visible = false;
                    pnlNoItems.Visible = true;
                    lblItemCount.Text = "0";
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "<strong>Database Error:</strong> Could not load items. " + Server.HtmlEncode(ex.Message));
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                pnlAlert.Visible = false;

                string partNo = txtPartNo.Text.Trim();
                string itemName = txtItemName.Text.Trim();
                string location = txtLocation.Text.Trim();
                string priceText = txtUnitPrice.Text.Trim();
                string isEditMode = hdnIsEditMode.Value;

                // Validation
                if (string.IsNullOrWhiteSpace(partNo))
                {
                    ShowAlert("warning", "Part Number is required. Please specify a unique code (e.g., P-1011).");
                    txtPartNo.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(itemName))
                {
                    ShowAlert("warning", "Item Name is required.");
                    txtItemName.Focus();
                    return;
                }

                decimal unitPrice;
                if (!decimal.TryParse(priceText, out unitPrice) || unitPrice < 0)
                {
                    ShowAlert("warning", "Unit Price must be a valid number greater than or equal to 0.00.");
                    txtUnitPrice.Focus();
                    return;
                }

                if (string.IsNullOrWhiteSpace(location))
                {
                    ShowAlert("warning", "Storage Location is required (e.g. Warehouse A - Rack 01).");
                    txtLocation.Focus();
                    return;
                }

                if (isEditMode == "1")
                {
                    // Update Mode
                    ItemRepository.UpdateItem(partNo, itemName, unitPrice, location);
                    ShowAlert("success", string.Format("Item <strong>{0}</strong> ({1}) was successfully updated.", Server.HtmlEncode(partNo), Server.HtmlEncode(itemName)));
                    ResetForm();
                }
                else
                {
                    // Create Mode
                    int openingQty = 0;
                    if (!string.IsNullOrWhiteSpace(txtCurrentQuantity.Text))
                    {
                        if (!int.TryParse(txtCurrentQuantity.Text.Trim(), out openingQty) || openingQty < 0)
                        {
                            ShowAlert("warning", "Opening Stock Quantity must be a non-negative integer (0 or greater).");
                            txtCurrentQuantity.Focus();
                            return;
                        }
                    }

                    // Check for duplicate Part Number
                    if (ItemRepository.PartNoExists(partNo))
                    {
                        ShowAlert("danger", string.Format("<strong>Duplicate Part Number Blocked:</strong> Part Number '<strong>{0}</strong>' already exists in the system. Duplicate Part Numbers are not permitted.", Server.HtmlEncode(partNo)));
                        txtPartNo.Focus();
                        return;
                    }

                    ItemRepository.InsertItem(partNo, itemName, unitPrice, location, openingQty);
                    ShowAlert("success", string.Format("New item '<strong>{0}</strong>' ({1}) was successfully registered into Item Master.", Server.HtmlEncode(partNo), Server.HtmlEncode(itemName)));
                    ResetForm();
                }

                BindItemList(txtSearch.Text.Trim());
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "<strong>Operation Failed:</strong> " + Server.HtmlEncode(ex.Message));
            }
        }

        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                string partNo = e.CommandArgument.ToString();
                DataRow row = ItemRepository.GetItemByPartNo(partNo);
                if (row != null)
                {
                    txtPartNo.Text = row["PartNo"].ToString();
                    txtPartNo.ReadOnly = true;
                    txtPartNo.CssClass = "form-control readonly";

                    txtItemName.Text = row["ItemName"].ToString();
                    txtUnitPrice.Text = Convert.ToDecimal(row["UnitPrice"]).ToString("F2");
                    txtLocation.Text = row["Location"].ToString();

                    // Hide opening quantity in edit mode (stock must be adjusted via transactions)
                    divOpeningQty.Visible = false;

                    hdnIsEditMode.Value = "1";
                    lblFormTitle.Text = "✏️ Edit Item: " + partNo;
                    btnSave.Text = "💾 Update Item";

                    ShowAlert("info", "Editing item <strong>" + Server.HtmlEncode(partNo) + "</strong>. Primary key is locked.");
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            pnlAlert.Visible = false;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindItemList(txtSearch.Text.Trim());
        }

        protected void btnResetSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindItemList();
        }

        private void ResetForm()
        {
            txtPartNo.Text = "";
            txtPartNo.ReadOnly = false;
            txtPartNo.CssClass = "form-control";

            txtItemName.Text = "";
            txtUnitPrice.Text = "";
            txtLocation.Text = "";
            txtCurrentQuantity.Text = "0";

            divOpeningQty.Visible = true;
            hdnIsEditMode.Value = "0";
            lblFormTitle.Text = "➕ Register New Inventory Item";
            btnSave.Text = "💾 Save Item";
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
