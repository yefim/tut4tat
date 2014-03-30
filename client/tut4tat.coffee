DEFAULT_HOURS = 5

Meteor.subscribe "userData"

$.fn.serializeObject = ->
  o = {}
  a = @serializeArray()
  $.each a, ->
    if o[@name]
      o[@name] = [o[@name]] unless o[@name].push
      o[@name].push @value or ""
    else
      o[@name] = @value or ""
  return o

pluralize = (count, word) ->
  if count is 1 then "#{count} #{word}" else "#{count} #{word}s"

getTimestamp = ({hour, weekday}) ->
  return Date.now()

Template.layout.events
  'click .logout': ->
    Session.set "message", "Logged out successfully."
    setTimeout (-> Session.set "message"), 2000
    Meteor.logout()
    Router.go "index"

Template.layout.helpers
  error: -> Session.get "error"
  message: -> Session.get "message"
  pluralize: pluralize

Template.login.events
  'submit .login-form': (e) ->
    e.preventDefault()
    form = $('.login-form').serializeObject()
    Meteor.loginWithPassword {email: form.email}, form.password, (err) ->
      if err
        Session.set "error", err.toString()
      else
        Session.set "message", "Logged in successfully."
        setTimeout (-> Session.set "message"), 2000
        Router.go 'index'

Template.signup.events
  'submit .signup-form': (e) ->
    e.preventDefault()
    form = $('.signup-form').serializeObject()
    if form.password == form.confirm
      user =
        email: form.email
        password: form.password
        profile:
          name: form.name
          hours: DEFAULT_HOURS
          skills: []
          availability: []
      Accounts.createUser user, (err) ->
        if err
          Session.set "error", err.toString()
        else
          Session.set "message", "Account created successfully."
          setTimeout (-> Session.set "message"), 2000
          Router.go "/skills?signup=true"
    else
      Session.set "error", "Passwords don't match."

Template.skills.helpers
  isChecked: (skill) ->
    _.contains Meteor.user()?.profile?.skills, skill

Template.skills.events
  'submit .skills-form': (e) ->
    e.preventDefault()
    form = $('.skills-form').serializeObject()
    unless _.isArray form.skills
      form.skills = [form.skills]
    Meteor.users.update Meteor.userId(), {$set: {"profile.skills": form.skills}}

    Session.set "message", "Skills saved successfully."
    setTimeout (-> Session.set "message"), 2000
    if form.signup is "true"
      Router.go "/availability?signup=true"
    else
      Router.go "index"

Template.calendar.helpers
  isSelected: (availability, hour, weekday) ->
    selected = _.some availability, (a) ->
      return hour == a.hour and weekday == a.weekday
    if selected then 'selected' else ''

# buggy-ish when2meet clone
Template.availability.events
  'mousedown .hour': (e) ->
    Session.set('dragging', true)
    $(e.target).toggleClass "selected"
  'mouseup': (e) ->
    Session.set("dragging", false)
  'mouseenter .hour': (e) ->
    if Session.get("dragging")
      $(e.target).toggleClass "selected"
  'submit .availability-form': (e) ->
    e.preventDefault()
    form = $('.availability-form').serializeObject()
    availability = $('.hour.selected').map (i, e) ->
      {
        hour: $(e).data('hour')
        weekday: $(e).data('weekday')
      }
    availability = availability.toArray()

    Meteor.users.update Meteor.userId(), {$set: {"profile.availability": availability}}
    Session.set "message", "Availability saved successfully."
    setTimeout (-> Session.set "message"), 2000
    Router.go "index"

Template.user.helpers
  currentUserHours: -> Session.get "currentUserHours"
  pluralize: pluralize

Template.user.events
  'click .hour': (e) ->
    if $(e.target).hasClass("selected")
      if $(e.target).hasClass "scheduled"
        Session.set "currentUserHours", Session.get("currentUserHours") + 1
        $(e.target).toggleClass "scheduled"
      else if Session.get("currentUserHours") > 0
        Session.set "currentUserHours", Session.get("currentUserHours") - 1
        $(e.target).toggleClass "scheduled"
  'click .book': (e) ->
    e.preventDefault()
    scheduled = $('.hour.scheduled').map (i, e) ->
      {
        hour: $(e).data('hour')
        weekday: $(e).data('weekday')
      }
    scheduled = scheduled.toArray()

    Meteor.users.update Meteor.userId(), {$inc: {"profile.hours": -scheduled.length}}
    # should I find continuous intervals and book as one session?
    for session in scheduled
      Sessions.insert
        timestamp: getTimestamp session
        tutee: Meteor.userId()
        tutor: Session.get("userId")
    Session.set "message", "Tutor was booked successfully."
    setTimeout (-> Session.set "message"), 2000
    Router.go "index"
