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

    $("#sidebarToggle").on("click", function ()
    {
        $sidebarAndWrapper.toggleClass("hide-sidebar");
        if ($sidebarAndWrapper.hasClass("hide-sidebar"))
            $(this).text("Show Sidebar");
        else
            $(this).text("Hide Sidebar");
    });

}());