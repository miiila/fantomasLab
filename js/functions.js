// Generated by CoffeeScript 1.8.0
var countCmlTime, escapeString, finishCmlTask, finishFlash, flash, formatTime, formatTwoDigitTime, inputFocus, loadingSequence, openLocation, parseTime, processCommand, processResult, startCmlTask;

(function($) {})(jQuery);

loadingSequence = "<div class='terminalRow'>> ^1000 Starting CML connection </div> <div class='terminalRow'>> ^1000 Loading kernel </div> <div class='terminalRow'> > ^1000 Loading map</div>";

$(function() {
  $('input').val('');
  $('.nonStartup').hide();
  $('#typed').typed({
    strings: [loadingSequence],
    typeSpeed: 50,
    showCursor: true,
    callback: function() {
      $('.typed-cursor').hide();
      $('.nonStartup').show();
      return inputFocus();
    }
  });
  $(document).click(function() {
    return inputFocus();
  });
  $(document).keypress(function(event) {
    switch (event.keyCode) {
      case 9:
        event.preventDefault();
        return inputFocus();
      case 13:
        return processCommand($('#command'));
    }
  });
  inputFocus();
  return window.cmlTasksTimes = new Array();
});

inputFocus = function() {
  return $('input').focus();
};

processCommand = function(data) {
  var command;
  command = data.val();
  $('#typed').append("<div class='terminalRow'> > " + escapeString(command) + "</div>");
  return $.ajax({
    type: 'GET',
    url: '/processCommand/' + command,
    beforeSend: function() {
      return $('#command').val('Processing...');
    }
  }).done(processResult);
};

processResult = function(result) {
  return setTimeout(function() {
    var flashSign, location, _i, _len, _ref;
    switch (result.type) {
      case 'open':
        if (result.success) {
          flashSign = flash($('#granted'));
          openLocation(result.location);
        } else {
          flashSign = flash($('#denied'));
        }
        setTimeout(function() {
          return finishFlash(flashSign);
        }, 4000);
        break;
      case 'system':
        if (result.success && result.command === 'shutdown') {
          _ref = result.locations;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            location = _ref[_i];
            openLocation(location);
          }
          $('.cmlState').text('STOPPED');
          $('.cmlState').addClass('red');
          $('#cmlTasks').text('');
        } else {
          $('#command').val('unknown command');
        }
    }
    return $('#command').val('');
  }, 2000);
};

openLocation = function(locationId) {
  $('#' + locationId).removeClass('closed');
  return $('#' + locationId).addClass('opened');
};

startCmlTask = function(cmlTask) {
  var innerHtml;
  window.cmlTasksTimes.push({
    "id": cmlTask.id,
    "miliseconds": cmlTask.miliseconds
  });
  innerHtml = "<div class='quest_green'><span>" + cmlTask.name + "</span><span id=\"" + cmlTask.id + "\" class='floatRight'>" + cmlTask.time + "</span></div>";
  return $('#cmlTasks').append(innerHtml);
};

finishCmlTask = function(cmlTask) {
  var _i, _len, _ref, _results;
  $('#' + cmlTask.id).parent().remove();
  _ref = window.cmlTasksTimes;
  _results = [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    cmlTask = _ref[_i];
    if (cmlTask.id = cmlTask.id) {
      _results.push(cmlTask.finished = true);
    }
  }
  return _results;
};

formatTime = function(number, places) {
  if (number < (Math.pow(10, places - 1))) {
    if (number.length !== places) {
      number = '0' + number;
    }
  }
  return number;
};

formatTwoDigitTime = function(number) {
  return formatTime(number, 2);
};

parseTime = function(time) {
  var newTime, output;
  newTime = new Date(time);
  output = formatTwoDigitTime(newTime.getHours()) + ':' + formatTwoDigitTime(newTime.getMinutes()) + ':' + formatTwoDigitTime(newTime.getSeconds());
  return output;
};

flash = function(objectToFlash) {
  objectToFlash.toggleClass('hidden');
  return setInterval(function() {
    return objectToFlash.toggleClass('hidden');
  }, 700);
};

escapeString = function(str) {
  var div;
  div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
};

finishFlash = function(intervalVar) {
  clearInterval(intervalVar);
  return $('.sign').addClass('hidden');
};

countCmlTime = function() {
  var formattedTimeString, newTime, taskTime, taskTimeObject;
  return window.cmlTasksTimes = (function() {
    var _i, _len, _ref, _results;
    _ref = window.cmlTasksTimes;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      taskTime = _ref[_i];
      if (!((taskTime.finished != null) !== true)) {
        continue;
      }
      newTime = taskTime.miliseconds - (100 + window.balance);
      taskTimeObject = new Date(newTime);
      formattedTimeString = formatTwoDigitTime(taskTimeObject.getMinutes()) + ":" + formatTwoDigitTime(taskTimeObject.getSeconds());
      if (formattedTimeString === '03:00') {
        $('#' + taskTime.id).parent().removeClass('quest_green');
        $('#' + taskTime.id).parent().addClass('quest_red');
      }
      $('#' + taskTime.id).text(formattedTimeString);
      if (formattedTimeString === '00:00') {
        flash($('#' + taskTime.id).parent());
        setTimeout(function() {
          return window.location.reload();
        }, 5000);
        break;
      }
      _results.push({
        "miliseconds": newTime,
        "id": taskTime.id
      });
    }
    return _results;
  })();
};

//# sourceMappingURL=functions.js.map
