/// <reference path="../_all.ts" />
var ContactManagerApp;
(function (ContactManagerApp) {
    var MainController = (function () {
        //old way
        /*
        constructor(private $scope: any) {
            this.$scope.message = "Test the old way";
        }
        */
        function MainController(userService, $mdSidenav, $mdToast, $mdDialog, $mdMedia, $mdBottomSheet) {
            this.userService = userService;
            this.$mdSidenav = $mdSidenav;
            this.$mdToast = $mdToast;
            this.$mdDialog = $mdDialog;
            this.$mdMedia = $mdMedia;
            this.$mdBottomSheet = $mdBottomSheet;
            this.users = [];
            this.newNote = new ContactManagerApp.Note('', null);
            this.message = "Hello from Main Controller";
            this.selected = null;
            this.searchText = "";
            this.tabIndex = 0;
            var self = this;
            this.userService
                .loadAllUsers()
                .then(function (users) {
                self.users = users;
                self.selected = users[0];
                self.userService.selectedUser = self.selected;
                console.log(self.users);
            });
        }
        MainController.prototype.toggleSideNav = function () {
            this.$mdSidenav("left").toggle();
        };
        MainController.prototype.selectUser = function (user) {
            this.selected = user;
            this.userService.selectedUser = user;
            //close side nav
            var sidenav = this.$mdSidenav("left");
            if (sidenav.isOpen) {
                sidenav.close();
            }
            this.tabIndex = 0;
        };
        MainController.prototype.showContactOptions = function ($event) {            
            this.$mdBottomSheet.show({                
                parent: angular.element(document.getElementById("wrapper")),
                templateUrl: "/dist/views/contactSheet.html",
                controller: ContactManagerApp.ContactPanelController,
                controllerAs: "cp",
                bindToController: true,
                targetEvent: $event
            }).then(function (clickedItem) {
                clickedItem && console.log(clickedItem.name + " clicked");
            });
        };
        MainController.prototype.addUser = function ($event) {
            var self = this;
            var useFullScreen = (this.$mdMedia('sm') || this.$mdMedia('xs'));
            this.$mdDialog.show({
                templateUrl: "/dist/views/newUserDialog.html",
                parent: angular.element(document.body),
                targetEvent: $event,
                controller: ContactManagerApp.AddUserDialogController,
                controllerAs: 'ctrl',
                //bindToController: true,
                clickOutsideToClose: true,
                fullscreen: useFullScreen
            }).then(function (user) {
                var newUser = ContactManagerApp.User.fromCreate(user);
                self.users.push(newUser);
                self.selectUser(newUser);
                console.log('User added');
                self.openToast("User added");
            }, function () {
                console.log('You cancelled the dialog.');
            });
        };
        MainController.prototype.clearNotes = function ($event) {
            var confirm = this.$mdDialog.confirm()
                .title("Are you sure you want to delete all notes ?")
                .textContent("All notes will be deleted, you can\'t undo this action.")
                .targetEvent($event)
                .ok("Yes")
                .cancel("No");
            var self = this;
            this.$mdDialog.show(confirm)
                .then(function () {
                self.selected.notes = [];
                self.openToast("Cleared notes");
                confirm = null;
            });
        };
        MainController.prototype.setFormScope = function (scope) {
            this.formScope = scope;
        };
        MainController.prototype.addNote = function () {
            this.selected.notes.push(this.newNote);
            //reset form - remove dirty flag
            this.formScope.noteForm.$setUntouched();
            this.formScope.noteForm.$setPristine();
            this.newNote = new ContactManagerApp.Note('', null);
            this.openToast("Note was added.");
        };
        MainController.prototype.removeNote = function (note) {
            var foundIndex = this.selected.notes.indexOf(note);
            this.selected.notes.splice(foundIndex, 1);
            this.openToast("Note was removed.");
        };
        MainController.prototype.openToast = function (message) {
            this.$mdToast.show(this.$mdToast.simple()
                .capsule(true)
                .action("Action")
                .textContent(message)
                .position("top right")
                .hideDelay(3000))
                .then(function (result) {
                console.log("success");
                console.log(result);
            })
                .catch(function (reason) {
                console.log("error");
                console.log(reason);
            })
                .finally(function () {
                console.log("finally");
            });
        };
        MainController.$inject = [
            "userService",
            "$mdSidenav",
            "$mdToast",
            "$mdDialog",
            "$mdMedia",
            "$mdBottomSheet"];
        return MainController;
    }());
    ContactManagerApp.MainController = MainController;
})(ContactManagerApp || (ContactManagerApp = {}));
;
//# sourceMappingURL=mainController.js.map