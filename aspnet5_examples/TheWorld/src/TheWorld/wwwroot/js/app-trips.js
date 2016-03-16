//app-trips.js
(function () {
    
    "use strict";

    var app = angular.module("app-trips", ["simpleControls", "ngRoute"]);

    app.config(function($routeProvider){

        $routeProvider.when("/", {
            controller: "tripsController",
            controllerAs: "vm",
            templateUrl: "/views/tripsView.html",
        });

        $routeProvider.when("/editor/:tripName", {
            controller: "tripEditorController",
            controllerAs: "vm",
            templateUrl: "/views/tripEditorView.html",
        });
        
        $routeProvider.otherwise({
            redirectTo: "/"
        });

    });

}());