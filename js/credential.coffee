---
---
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

setCallbackUrlUI = (callback_url) ->
    $('#callback-url').val(callback_url)
    $('#callback-url').removeAttr('disabled')
    $('#callback-url').removeAttr('readonly')

setAccountInfoUI = (api_key, test_api_key) ->
    $('#credential-api-key').val(api_key)
    $('#credential-test-api-key').val(test_api_key)
    if api_key!= 'N/A'
        $('#credential-api-key').removeAttr('disabled')
    if test_api_key != 'N/A'
        $('#credential-test-api-key').removeAttr('disabled')

tryFetchLatestInfo = () ->
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email
    eemeConsole.utils.get url, {}, (data) ->
        if $('#credential-client-id').val() == data.service_account[0].client_id
            setTimeout(tryFetchLatestInfo, 1000)
        else
            # call it again in order not to write more code :)
            getCredentials()

updateCallbackUrlBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CALLBACKURL_URL + "/" + email
    callback_url = $("[name=callback-url]").val()
    data =
        callback_url: callback_url
    eemeConsole.utils.post url, data, (data) ->
        if data.callback_url == callback_url
            alert("Update successfully")

createAccountBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email
    eemeConsole.utils.post url, {}, (data) ->
        setAccountInfoUI(data.api_key, data.test_api_key)

getCredentials = () ->
    # get credentials
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CREDENTIAL_URL + "/" + email
    eemeConsole.utils.get url, {}, (data) ->
        api_key = 'N/A'
        test_api_key = 'N/A'
        if data.api_key != ""
            api_key = data.api_key
        if data.test_api_key != ""
            test_api_key = data.test_api_key

        setAccountInfoUI(api_key, test_api_key)

getCallbackUrl = () ->
    # get credentials
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.CALLBACKURL_URL+ "/" + email
    eemeConsole.utils.get url, {}, (data) ->
        callback_url = 'N/A'
        if data.callback_url != ""
            callback_url = data.callback_url

        setCallbackUrlUI(callback_url)

$(document).ready ->
    # bind handler
    $('#create-service-account-btn').click(createAccountBtnHandler)
    $('#update-callback-url-btn').click(updateCallbackUrlBtnHandler)
    getCredentials()
    getCallbackUrl()

