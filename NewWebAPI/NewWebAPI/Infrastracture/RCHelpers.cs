using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace NewWebAPI.Infrastracture
{
    public static class RCHelpers
    {
        public static MvcHtmlString LinkSimple(this HtmlHelper helper, string href, string text)
        {
            var builder = new TagBuilder("a");
            builder.MergeAttribute("href", href);
            builder.InnerHtml = text;
            return MvcHtmlString.Create(builder.ToString());
        }        
    }
}