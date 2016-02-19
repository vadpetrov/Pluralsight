(function () {

    var app = angular.module("githubViewer", []);

    app.controller('MainController',
                ["$scope", "$http", "$interval",
                "$log", "$anchorScroll", "$location",
                MainController]);


    function MainController(scope, http, interval, log,
                            anchorScroll, location) {

        var onUserComplete = function (response) {
            scope.user = response.data;
            http.get(scope.user.repos_url)
              .then(onRepos, onError);
        };

        var onRepos = function (response) {
            scope.repos = response.data;
            location.hash("userDetails");
            anchorScroll();
        };

        var onError = function (reason) {
            scope.error = "Could not fetch the data.";
            scope.reason = reason;
        };

        var decrementCountdown = function () {
            scope.countdown -= 1;
            if (scope.countdown < 1)
                scope.search(scope.username);
        };

        var countdownInterval = null;
        var startCountdown = function () {
            //countdownInterval = interval(decrementCountdown, 1000, scope.countdown);
        };


        scope.search = function (username) {

            log.info("Searching for " + username);
            scope.error = null;
            scope.reason = null;

            //if (username == null) return;

            http.get("https://api.github.com/users/" + username)
              .then(onUserComplete, onError);

            if (countdownInterval) {
                interval.cancel(countdownInterval);
                scope.countdown = "";
            }
        };

        scope.username = "Angular";
        scope.message = "GitHub Viewer";
        scope.repoSortOrder = "-stargazers_count";
        scope.template_user_details = "GitHub_userdetails.html";
        scope.countdown = 5;
        startCountdown();
    };

}());

(function () {

    var app = angular.module("githubViewer1", []);

    var MainController = function (s, h) {

        var onUserComplete = function (response) {
            s.user = response.data;
        };
        var onError = function (reason) {
            s.error = "Could not fetch the user.";
        };

        h.get("https://api.github.com/users/robconery")
          .then(onUserComplete, onError);

        s.message = "Hello, Angular 2";
    };

    app.controller('MainController', ["$scope", "$http", MainController]);

}());



(function () {

    var app = angular.module("githubViewer2", []);
    app.controller('MainController', MainController);

    function MainController($scope, $http) {

        var onUserComplete = function (response) {
            $scope.user = response.data;
        };
        var onError = function (reason) {
            $scope.error = "Could not fetch the user.";
        };

        $http.get("https://api.github.com/users/robconery")
          .then(onUserComplete, onError);

        $scope.message = "Hello, Angular 1";
    };

}());