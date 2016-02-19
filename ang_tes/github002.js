
//Controller with custom github "service"
(function () {

    var module = angular.module("githubViewer", []);

    module.controller('MainController', ["$scope", "github", "$interval", "$log", "$anchorScroll", "$location",
      MainController
    ]);


    function MainController(scope, github, interval, log,
      anchorScroll, location) {

        var onUserComplete = function (data) {
            scope.user = data;
            github.getRepos(scope.user).then(onRepos, onError);
        };

        var onRepos = function (data) {
            scope.repos = data;
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
            countdownInterval = interval(decrementCountdown, 1000, scope.countdown);
        };

        scope.search = function (username) {

            log.info("Searching for " + username);
            scope.error = null;
            scope.reason = null;

            //if (username == null) return;

            github.getUser(username)
              .then(onUserComplete, onError);

            if (countdownInterval) {
                interval.cancel(countdownInterval);
                scope.countdown = "";
            }
        };

        scope.username = "Angular";
        scope.message = "GitHub Viewer 3";
        scope.repoSortOrder = "-stargazers_count";
        scope.template_user_details = "github_userdetails.html";
        scope.countdown = 5;
        startCountdown();
    };

}());



//Controller with custom github "service"
(function () {

    var app = angular.module("githubViewer222222", []);

    app.controller('MainController', MainController);

    function MainController($scope, github, $interval, $log,
      $anchorScroll, $location) {

        var onUserComplete = function (data) {
            $scope.user = data;
            github.getRepos($scope.user).then(onRepos, onError);
        };

        var onRepos = function (data) {
            $scope.repos = data;
            $location.hash("userDetails");
            $anchorScroll();
        };

        var onError = function (reason) {
            $scope.error = "Could not fetch the data.";
            $scope.reason = reason;
        };

        var decrementCountdown = function () {
            $scope.countdown -= 1;
            if ($scope.countdown < 1)
                $scope.search($scope.username);
        };

        var countdownInterval = null;
        var startCountdown = function () {
            countdownInterval = $interval(decrementCountdown,1000,$scope.countdown);
        };

        $scope.search = function (username) {

            $log.info("Searching for " + username);
            $scope.error = null;
            $scope.reason = null;

            if (username == null) return;

            github.getUser(username)
              .then(onUserComplete, onError);

            if (countdownInterval) {
                $interval.cancel(countdownInterval);
                $scope.countdown = "";
            }
        };

        $scope.username = "Angular";
        $scope.message = "GitHub Viewer 2";
        $scope.repoSortOrder = "-stargazers_count";
        $scope.template_user_details = "github_userdetails.html";
        $scope.countdown = 5;
        startCountdown();
    };

}());



//Controller without custom github "service"
(function () {

    var app = angular.module("githubViewer1111", []);

    app.controller('MainController', ["$scope", "$http", "$interval", "$log", "$anchorScroll", "$location",
      MainController
    ]);

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
            countdownInterval = interval(decrementCountdown,1000,scope.countdown);
        };

        scope.search = function (username) {

            log.info("Searching for " + username);
            scope.error = null;
            scope.reason = null;

            if (username == null) return;

            http.get("https://api.github.com/users/" + username)
              .then(onUserComplete, onError);

            if (countdownInterval) {
                interval.cancel(countdownInterval);
                scope.countdown = "";
            }
        };

        scope.username = "Angular";
        scope.message = "GitHub Viewer 1";
        scope.repoSortOrder = "-stargazers_count";
        scope.template_user_details = "github_userdetails.html";
        scope.countdown = 5;
        startCountdown();
    };

}());