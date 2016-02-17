/// <reference path="jquery-2.1.0-vsdoc.js" />
/// <reference path="jquery-ui-1.11.4.js" />

$(document).ready(function () {

    $(":input[data-autocomplete]").each(function() {

        $(this).autocomplete({source: $(this).attr("data-autocomplete")});
    });

    $(":input[data-datepicker]").datepicker();
    //$("#DiningDate").datepicker();
    

    $("#searchForm").submit(function () {
        $.getJSON($(this).attr("action"),  // the url to get JSON from
                  $(this).serialize(),     // make q=yellow, for example
                  function (data) {      // what to do with the response
                    var result = $("#searchTemplate").tmpl(data);
                    $("#searchResultsJSON").empty()
                               .append(result);
                }
        );
        return false;
    });
})