getHour = (h) ->
  if h >= 12
    h -= 12
    d = "pm"
  else
    d = "am"
  if h == 0
    h = 12
  return h + d
HOURS = ({value: h, display: getHour h} for h in [0..23])
WEEKDAYS = [ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" ]

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
      {
        signup: @params.signup is "true"
        availability: Meteor.user()?.profile?.availability
        weekdays: WEEKDAYS
        hours: HOURS
      }

  @route "session",
    path: "/t/:_id"
    template: "session"
    data: -> {}

  @route "user",
    path: "/u/:_id"
    template: "user"
    before: ->
      Session.set "error" # clear error
      Session.set "currentUserHours", Meteor.user()?.profile?.hours or 0
    data: ->
      Session.set "userId", @params._id
      user = Meteor.users.findOne(_id: @params._id)
      {
        user: user
        weekdays: WEEKDAYS
        hours: HOURS
        availability: user?.profile?.availability
      }
