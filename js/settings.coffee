---
---

PROTOCOL = location.protocol
global =
    API_BASE_URL: PROTOCOL + '//api.energyefficiency.me/v1/console'
    CONSOLE_BASE_URL: window.location.origin # for production

# IMPORTANT!! for development environment
if window.location.hostname == "127.0.0.1" or window.location.hostname == "localhost"
    global.CONSOLE_BASE_URL = global.CONSOLE_BASE_URL


setting =
    API:
        LOGIN_URL: global.API_BASE_URL + '/login'
        CREDENTIAL_URL: global.API_BASE_URL + '/credential'
        CALLBACKURL_URL: global.API_BASE_URL + '/callback'
        SSHKEY_URL: global.API_BASE_URL + '/ssh'
        SIGNUP_URL: global.API_BASE_URL + '/signup'
        FEEDBACK_URL: global.API_BASE_URL + '/feedback'
    CONSOLE:
        BASE_URL: global.CONSOLE_BASE_URL
        LOGIN_URL: global.CONSOLE_BASE_URL + '/login'
        SIGNUP_URL: global.CONSOLE_BASE_URL + '/signup'
console =
    global: global
    setting: setting

window.eemeConsole = console


# set base url
# this solve the relative url issue
# uncomment this line if you want to test locally
#$('head').append("<base href=\"#{global.CONSOLE_BASE_URL}/\">")

# For close button.
$(document).on "click", ".close", (event) ->
    $(this).parent().hide()
# For feedback button.
$(document).on "click", "#feedback-btn", (event) ->
    $("#feedback-div").show()
$(document).on "click", "#feedback-submit-btn", (event) ->
    event.preventDefault()
    purpose = $("input[name='purpose']").val()
    feedback = $("textarea[name='feedback']").val()
    if (purpose == "" && feedback == "")
        alert("Please don't leave all fields empty.")
        return
    url = eemeConsole.setting.API.FEEDBACK_URL
    data =
        'purpose': purpose
        'feedback': feedback
    $.post(url, data, (data) ->
        alert("Thanks for your feedback!")
        $("input[name='purpose']").val("")
        $("textarea[name='feedback']").val("")
        $("#feedback-div").hide()
    ).error ->
        alert("Sorry! Something went wrong.")

