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
    data: ->
      tutors = Meteor.users.find()
      # Meteor.users.find({skills: {$existing: true}, availability: {$existing: true}})
      {tutors}

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
    data: ->
      {
        signup: @params.signup is "true"
        skills: [ "Math", "Computer Science", "English", "French", "Spanish" ]
      }

  @route "availability",
    path: "/availability"
    template: "availability"
    data: ->
      getHour = (h) ->
        if h >= 12
          h -= 12
          d = "pm"
        else
          d = "am"
        if h == 0
          h = 12
        return h + d
      hours = ({value: h, display: getHour h} for h in [0..23])
      {
        signup: @params.signup is "true"
        weekdays: [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]
        hours: hours
      }

  @route "session",
    path: "/t/:_id"
    template: "session"
    data: -> {}

  @route "user",
    path: "/u/:_id"
    template: "user"
    data: -> Meteor.users.findOne(_id: @params._id)
