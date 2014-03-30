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

Template.layout.events
  'click .logout': ->
    Session.set "message", "Logged out successfully."
    setTimeout (-> Session.set "message"), 2000
    Meteor.logout()
    Router.go "index"

Template.layout.helpers
  error: -> Session.get "error"
  message: -> Session.get "message"

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

Template.availability.helpers
  isSelected: (hour, weekday) ->
    selected = _.some Meteor.user()?.profile?.availability, (a) ->
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
