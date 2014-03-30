Meteor.publish "userData", ->
  Meteor.users.find {}, {fields:
    "profile.name": 1
    "profile.availability": 1
    "profile.skills": 1
    "profile.hours": 1 }
