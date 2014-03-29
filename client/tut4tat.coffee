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
  'click .logout': -> Meteor.logout()

Template.layout.helpers
  error: -> Session.get "error"

Template.index.helpers
  tutors: ->
    Meteor.users.find()
    # need to publish tutor names and availability and skills
    # Meteor.users.find({skills: {$existing: true}, availability: {$existing: true}})

Template.login.events
  'submit .login-form': (e) ->
    e.preventDefault()
    form = $('.login-form').serializeObject()
    Meteor.loginWithPassword {email: form.email}, form.password, (err) ->
      if err
        Session.set "error", err.toString()
      else
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
      Accounts.createUser user, (err) ->
        if err
          Session.set "error", err.toString()
        else
          Router.go "skills"
    else
      Session.set "error", "Passwords don't match."
