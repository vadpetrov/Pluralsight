(function () {

    var module = angular.module("githubViewer");

    module.controller('UserController', ["$scope", "github", "$routeParams", UserController]);

    function UserController(scope, github, routeParams) {

        console.log("ucr");


        var onUserComplete = function (data) {
            scope.user = data;
            github.getRepos(scope.user).then(onRepos, onError);
        };

        var onRepos = function (data) {
            scope.repos = data;
        };

        var onError = function (reason) {
            scope.error = "Could not fetch the data.";
            scope.reason = reason;
        };

        scope.username = routeParams.username;
        scope.repoSortOrder = "-stargazers_count";

        github.getUser(scope.username).then(onUserComplete, onError);
    };

}());