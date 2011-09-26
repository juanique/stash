isCharacterKeyPress = (evt) ->
    nonPrintable = [16, 37, 38, 39, 40, 33, 34, 35, 36, 45,93,91, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123]
    if typeof evt.which == "undefined"
        return true
    else
        return evt.which not in nonPrintable and not evt.ctrlKey and not evt.metaKey and not evt.altKey

smart_keyup = (jqInput, callback) ->
    trKeyUp = false
    minTime = 200
    last_value = 'not_a_value'
    jqInput.keyup (event) ->
        clearTimeout trKeyUp
        trKeyUp = setTimeout (=>
            if value != last_value
                value = $(this).val()
                last_value = value
                callback(value)
        ),minTime

$(document).ready ->
    jqKey = $('#inputKey')
    jqValue = $('#inputValue')

    #console.debug('Initializing socket...')
    socket = io.connect "http://" + window.location.host
    socket.on "info", (data) ->
        console.log data
    socket.on "warn", (data) ->
        console.warn data
    socket.on "get_value", (data) ->
        jqValue.val data
    
    jqKey.keydown (event) ->
        if event.keyCode != 9 and ((isCharacterKeyPress event) or event.keyCode == 8)
            jqValue.val ""

    smart_keyup jqKey, (value) -> socket.emit('get_value', value)
    smart_keyup jqValue, (value) ->
        socket.emit 'set_value',
            key : jqKey.val()
            value: jqValue.val()
