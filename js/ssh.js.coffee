setSSHKeyUI = (fingerprint, comment) ->
    $("#ssh-key-div").empty()
    if fingerprint != ""
        html = "<h3>"+comment+"</h2>"
        html += "<h4>" + fingerprint + "</h3>"
        $("#ssh-key-div").append(html)
    else
        $("#modal-open-btn").html("Assign SSH Key")


getSSHKeys = () ->
    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.SSHKEY_URL+ "/" + email

    eemeConsole.utils.get url, {}, (data) ->
        fingerprint = data.fingerprint
        comment = data.comment

        setSSHKeyUI(fingerprint, comment)

modalOpenBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    openUpdateModal()

updateKeyBtnHandler = (event) ->
    event.preventDefault()
    event.stopPropagation()
    key = $("#public-key").val()
    $("#updateModal").foundation('reveal', 'close')

    email = eemeConsole.auth.getEmail()
    url = eemeConsole.setting.API.SSHKEY_URL+ "/" + email
    data =
        key: key
    eemeConsole.utils.post url, data, (data) ->
        alert("Update successfully")
        setSSHKeyUI(data.fingerprint, data.comment)

openUpdateModal = (event) ->
    $("#public-key").val("")
    $("#updateModal").foundation('reveal', 'open')

$(document).ready ->
    # bind handler
    $("#ssh-key-update-btn").click(updateKeyBtnHandler)
    $("#modal-open-btn").click(modalOpenBtnHandler)
    getSSHKeys()

