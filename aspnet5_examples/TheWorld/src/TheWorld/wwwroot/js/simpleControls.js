//simpleControls.js

(function () {

    "use strict";

    angular.module("simpleControls", [])
        .directive("waitCursor", waitCursor);

    function waitCursor() {

        return {
            scope:{
                show: "=displayWhen"
            },
            restrict: "E",
            templateUrl: "/views/waitCursor.html"
        };
    };

}());


(function () {
    
    "use strict";

    angular.module("datePickerControl", [])
        .directive("datepicker", datePicker);

    function datePicker() {
        
        return { 
            restrict: "A",
            require:"ngModel",
            link: attachPicker,
            scope: {
                dateformat: "@dateFormat",
                datevalue: "@dateValue"               
            }
        };
    };

    function attachPicker(scope, elem, attrs, ngModelCtrl) {
               

        var updateModel = function (dateText) 
        {
            scope.$apply(function () {
                ngModelCtrl.$setViewValue(dateText);

            });
        };

        var options = {
            dateFormat: (scope.dateformat ? scope.dateformat : "dd-mm-yy"),            
            onSelect: function (dateText) { updateModel(dateText); }
        };
        
        elem.datepicker(options);
        if (scope.datevalue!=null && scope.datevalue != "") updateModel(scope.datevalue);
    };

}());