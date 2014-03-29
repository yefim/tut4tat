Router.map ->
  @route "index",
    path: "/"
    template: "index"
    data: -> {}

  @route "session",
    path: "/t/:id"
    template: "session"
    data: -> {}
