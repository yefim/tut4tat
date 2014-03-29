Router.configure
  layoutTemplate: 'layout'
  notFoundTemplate: 'notFound'
  loadingTemplate: 'loading'
  before: ->
    Session.set "error" # clear error

Router.map ->
  @route "index",
    path: "/"
    template: "index"
    data: -> {}

  @route "login",
    path: "/login"
    template: "login"
    data: -> {}

  @route "signup",
    path: "/signup"
    template: "signup"
    data: -> {}

  @route "skills",
    path: "/skills"
    template: "skills"
    data: -> {}

  @route "availability",
    path: "/availability"
    template: "availability"
    data: -> {}

  @route "session",
    path: "/t/:id"
    template: "session"
    data: -> {}
