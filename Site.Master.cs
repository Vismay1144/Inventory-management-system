using System;
using System.IO;
using System.Web.UI;

namespace StockInventorySystem
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Returns 'active' CSS class if the current request matches the specified page name.
        /// </summary>
        public string GetNavClass(string pageName)
        {
            string currentPath = Request.Url.AbsolutePath;
            string currentPage = Path.GetFileName(currentPath);

            if (string.IsNullOrEmpty(currentPage) && pageName.Equals("Default.aspx", StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            return currentPage.Equals(pageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
        }
    }
}
