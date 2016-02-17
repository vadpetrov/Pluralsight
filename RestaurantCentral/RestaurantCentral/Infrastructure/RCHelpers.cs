using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace RestaurantCentral.Infrastructure
{
    public static class RCHelpers
    {
        public static MvcHtmlString Image(this HtmlHelper helper, string src, string altText)
        {
            var builder = new TagBuilder("img");
            builder.MergeAttribute("src", src);
            builder.MergeAttribute("alt", altText);
            return MvcHtmlString.Create(builder.ToString(TagRenderMode.SelfClosing));
            //html image 
        }
        public static string Image1(this HtmlHelper helper, string src, string altText)
        {
            var builder = new TagBuilder("img");
            builder.MergeAttribute("src", src);
            builder.MergeAttribute("alt", altText);
            return builder.ToString(TagRenderMode.SelfClosing);
            //html image code
        }

        public static MvcHtmlString LinkSimple(this HtmlHelper helper, string href, string text)
        {
            var builder = new TagBuilder("a");
            builder.MergeAttribute("href", href);
            builder.InnerHtml = text;
            return MvcHtmlString.Create(builder.ToString());
        }
    }
}