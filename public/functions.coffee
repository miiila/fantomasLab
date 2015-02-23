#################
#OnLoad Handlers#
#################

(($) ->

) jQuery

loadingSequence = "<div class='terminalRow'>> ^1000 Starting CML connection </div> <div class='terminalRow'>> ^1000 Loading kernel </div> <div class='terminalRow'> > ^1000 Loading map</div>"

$( ->
  $('input').val('')
  $('.nonStartup').hide()

  $('#typed').typed(
    strings: [loadingSequence],
    typeSpeed: 50,
    showCursor: true
    callback: ->
      $('.typed-cursor').hide()
      $('.nonStartup').show()
      inputFocus()
  )


  $(document).click( ->
    inputFocus()
  )
  $(document).keypress((event) ->
    switch event.keyCode
      when 9
        event.preventDefault();
        inputFocus();
      when 13
        processCommand($('#command'))
  )
  $('.sign').hide();
  inputFocus();
)

inputFocus = ->
  $('input').focus()

#################
#Submit handlers#
#################
processCommand = (data) ->
  command = data.val()
  $('#typed').append("<div class='terminalRow'> > " + escapeString(command) + "</div>")
  $.ajax(
    type: 'GET',
    url: '/processCommand/' + command,
    beforeSend: ->
      $('#command').val('Processing...')
  ).done(processResult)

processResult = (result) ->
  setTimeout(->
    switch result.type
      when 'open'
        if result.success
          flashSign = flash($('#granted'))
          openLocation(result.location)
        else
          flashSign = flash($('#denied'))
        setTimeout(->
            clearInterval(flashSign)
          ,3000)
        $('.sign').hide()
      when 'system'
        if result.success && result.command == 'shutdown'
            openLocation(location) for location in result.locations
            $('.cmlState').text('STOPPED')
            $('.cmlState').addClass('red')
        else
          $('#command').val('unknown command')
      #Clear input form
    $('#command').val('')
  ,2000)




openLocation = (locationId) ->
  $('#'+locationId).removeClass('closed')
  $('#'+locationId).addClass('opened')

################
#Util functions#
################
formatTime = (number,places) ->
  if number < (10 ** (places-1))
    unless number.length == places
      number = '0' + number
  return number

formatTwoDigitTime = (number) ->
  return formatTime(number,2)

parseTime = (time) ->
  newTime = new Date(time);
  output = formatTwoDigitTime(newTime.getHours()) + ':' + formatTwoDigitTime(newTime.getMinutes()) + ':' + formatTwoDigitTime(newTime.getSeconds());
  return output;

flash = (objectToFlash) ->
  objectToFlash.toggle()
  setInterval(->
    objectToFlash.toggle()
  ,500)
  
# http://shebang.brandonmintern.com/foolproof-html-escaping-in-javascript/
escapeString = (str) ->
  div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;