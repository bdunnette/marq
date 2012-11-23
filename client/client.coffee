### Config
############################################################################################################
# TODO: figure out how to store additional user info in the user profile and then ask for these additional scopes
# Accounts.ui.config
#   requestPermissions:
#     facebook: ["user_about_me", "user_activities", "user_birthday", "user_checkins", "user_education_history", "user_interests", "user_likes", "friends_likes", "user_work_history", "email"]

Meteor.subscribe('questions')


### Answer Question
############################################################################################################
Template.answerQuestion.events 
	"click button.answer": (event, template) ->
		event.preventDefault()
		Session.set("answerQuestionAlert", null)
		questionId = $("#answer-question").attr('data-question')
		answer = event.currentTarget.getAttribute('data-answer')
		#
		Meteor.call "answerQuestion", {
			questionId: questionId
			answer: answer
		}, (error, question) ->
			if error
				Session.set("answerQuestionAlert", {type: 'error', message: error.reason})
			else
				Session.set("answerQuestionAlert", {type: 'success', message: 'Thanks for your response. Please rate this question.', dismiss: true})
				Session.set("previousQuestionId", questionId)

	"click button.vote": (event, template) ->
		event.preventDefault()
		Session.set("answerQuestionAlert", null)
		questionId = $("#rate-question").attr('data-question')
		vote = event.currentTarget.getAttribute('data-vote')
		#
		Meteor.call "rateQuestion", {
			questionId: questionId
			vote: vote
		}, (error, question) ->
			if error
				Session.set("answerQuestionAlert", {type: 'error', message: error.reason})
			else
				Session.set("answerQuestionAlert", {type: 'success', message: 'Thanks for your feedback. Please respond to another question.', dismiss: true})
				Session.set("previousQuestionId", null)


Template.answerQuestion.question = ->
	Questions.findOne( { $or : [ { answers: { $size: 0 } } , {"answers.user" : { $ne : @userId } }] }, { sort: { voteTally: -1, createdAt: -1 } } )

Template.answerQuestion.alert = ->
	Session.get "answerQuestionAlert"

Template.answerQuestion.previousQuestion = ->
	Questions.findOne(Session.get("previousQuestionId"))


### New Question
############################################################################################################
Template.newQuestion.events 
	"click button.save": (event, template) ->
		event.preventDefault()
		Session.set("newQuestionAlert", null)
		question = Session.get 'question'
		answerChoices = Session.get 'answerChoices'
		Meteor.call "createQuestion", {
			question: question
			answerChoices: answerChoices
		}, (error, question) ->
			if error
				Session.set("newQuestionAlert", {type: 'error', message: error.reason})
			else
				Session.set("newQuestionAlert", {type: 'success', message: 'Question successfully asked. We will automatically show your question to randomly selected people. But you will get the best results if you invite more people to answer your question.', dismiss: true})
				Session.set("question", '')
				Session.set("answerChoices", null)
	
	"click .answer-choice-wrap .remove": (event, template) ->
		event.preventDefault()
		Session.set 'answerChoices', _.without(Session.get('answerChoices'), event.currentTarget.getAttribute('data-value'))

	"keypress input.answer-choice": (event, template) ->
		if (event.which == 13) then $(event.target).focusNextInputField()

	"blur textarea.question": (event, template) ->
		Session.set 'question', $.trim(event.currentTarget.value)

	"blur input.answer-choice": (event, template) ->
		Session.set 'answerChoices', _.without(_.uniq(_.map(template.findAll("input.answer-choice"), (el) -> $.trim(el.value))), '')


Template.newQuestion.alert = ->
	Session.get "newQuestionAlert"

Template.newQuestion.question = ->
	Session.get "question"

Template.newQuestion.objectifiedAnswerChoices = ->
	answerChoices = Session.get 'answerChoices'
	if answerChoices and answerChoices.length > 0
		objectifiedAnswerChoices = objectifyAnswerChoices(answerChoices)
		objectifiedAnswerChoices.push({order: answerChoices.length+1, placeholder: 'add another response', value: ''}, {order: answerChoices.length+2, placeholder: 'press enter to add another', value: ''})
	else
		objectifiedAnswerChoices = [{order: 1, placeholder: 'yes', value: ''}, {order: 2, placeholder: 'no', value: ''}, {order: 3, placeholder: "don't care", value: ''}]
	objectifiedAnswerChoices


### List Questions
############################################################################################################
Template.listQuestions.events 
	"click .questions-list .remove": (event, template) ->
		event.preventDefault()
		Questions.remove(event.currentTarget.getAttribute('data-questionId'))


Template.listQuestions.questions = ->
	Questions.find({ owner: @userId }, { sort: { createdAt: -1 } })

Template.listQuestions.questionCount = ->
	Template.listQuestions.questions().count()

Template.listQuestions.canRemove = ->
	@owner == Meteor.userId() and @.answerCount == 0


### Misc.
############################################################################################################
$.fn.focusNextInputField = ->
  @each ->
    fields = $(this).parents("form:eq(0),body").find("input,textarea,select")
    index = fields.index(this)
    fields.eq(index + 1).focus()  if index > -1 and (index + 1) < fields.length
    false

