(function () {

    var app = angular.module("app", []);
    app.controller('MainController', MainController);
    
    function MainController ($scope) {

        var person = {
            firstName: "Scott",
            lastName: "Allen",
            imageSrc: "http://odetocode.com/Images/scott_allen_2.jpg"
        };

        $scope.message = "Hello, Angular1";
        $scope.person = person;
    };

    /*
    var MainController = function ($scope) {

        var person = {
            firstName: "Scott",
            lastName: "Allen",
            imageSrc: "http://odetocode.com/Images/scott_allen_2.jpg"
        };

        $scope.message = "Hello, Angular1";
        $scope.person = person;
    };

    app.controller('MainController', MainController);
    */

}());
/*
(
    angular.module("app", [])

    .controller('MainController', function ($scope) {

        var person = {
            firstName: "Scott",
            lastName: "Allen",
            imageSrc: "http://odetocode.com/Images/scott_allen_2.jpg"
        };

        $scope.message = "Hello, Angular";
        $scope.person = person;
    })
);
*/

/*
(function () {

    var app = angular.module("app", []);

    app.controller('MainController', function ($scope)
    {
    
        var person = {
            firstName: "Scott",
            lastName: "Allen",
            imageSrc: "http://odetocode.com/Images/scott_allen_2.jpg"
        };

        $scope.message = "Hello, Angular";
        $scope.person = person;
    })


}());
*/