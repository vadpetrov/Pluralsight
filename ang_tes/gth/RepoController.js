(function () {

    var module = angular.module("githubViewer");

    module.controller('RepoController', ["$scope", "$routeParams", "github", RepoController]);

    function RepoController(scope, routeParams, github) {

        var onRepo = function (data) {
            scope.repo = data;
        };

        var onError = function (reason) {
            scope.error = reason;
        };


        var reponame = routeParams.reponame;
        var username = routeParams.username;        

        github.getRepoDetails(username, reponame)
          .then(onRepo, onError);

        scope.username = username;
        scope.reponame = reponame;
    };

}());