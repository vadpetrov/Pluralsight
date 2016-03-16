// site.js
(function () {

    //var ele = document.getElementById("username");
    //ele.innerHTML = "Vadim Petrov";

    /*
    var ele = $("#username");
    ele.text("Vadim Petrov");
    
    //var main = document.getElementById("main");
    var main = $("#main");

    main.on("mouseenter", function () {        
        main.css("background-color", "#888");
    });
    main.on("mouseleave", function () {
        main.css("background-color", "");
    });
    */

    /*
    main.onmouseenter = function () {
        main.style = "background-color:#888";
        main.style["background-color"] = "#888";
    };
    main.onmouseleave = function () {
        main.style = "";
        main.style["background-color"] = "";
    };
    */
    /*
    var menuItems = $("ul.menu li a");
    menuItems.on("click", function () {
        var me = $(this);        
        alert(me.text());    
    });
    */

    var $sidebarAndWrapper = $("#sidebar, #wrapper");
    var $icon = $("#sidebarToggle i.fa");

    $("#sidebarToggle").on("click", function ()
    {        
        $sidebarAndWrapper.toggleClass("hide-sidebar");
        if ($sidebarAndWrapper.hasClass("hide-sidebar"))
            //$(this).text("Show Sidebar");
            $icon.removeClass("fa-angle-double-left").addClass("fa-angle-double-right");
        else
            $icon.removeClass("fa-angle-double-right").addClass("fa-angle-double-left");
            //$(this).text("Hide Sidebar");
    });

}());