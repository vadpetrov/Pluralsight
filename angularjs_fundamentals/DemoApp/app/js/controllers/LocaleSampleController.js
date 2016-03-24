(function () {


    "use strict";

    var module = angular.module("eventsApp");
    module.controller("LocaleSampleController", LocaleSampleController);


    function LocaleSampleController($scope, $locale, tmhDynamicLocale) {
                
        
        function setLcl(locale) {

            tmhDynamicLocale.set(locale);
            $scope.$on("$localeChangeSuccess", function () {
                $scope.myFormat = $locale.DATETIME_FORMATS.fullDate;
            });
        };

        $scope.setEn = function () {

            setLcl("en");
        };
        $scope.setEs = function () {

            setLcl("es");
        };
        $scope.setFr = function () {

            setLcl("fr");
        };

        $scope.myDate = Date.now();
        $scope.myFormat = $locale.DATETIME_FORMATS.fullDate;
                

        //tmhDynamicLocale.set("en");
        //$scope.$on("$localeChangeSuccess", function () {
            //$scope.myFormat = $locale.DATETIME_FORMATS.fullDate;
        //});        
    };

}());