function chooseRandomly(){choices=$("input[type!='button']").removeClass("error").removeClass("chosen");var e=$("span.result").text("");if($(choices).each(function(){""===$(this).val()&&($(this).addClass("error"),$(e).text("All Choices must be filled, put 'nothing' if you must."))}),""===$(e).text()){var t=Math.floor(Math.random()*choices.length);$(e).text($(choices.get(t)).addClass("chosen").val())}}function addChoice(){var e=($("form input[type='text']").length+1).toString(),t=3==e?"rd":"th",o=$('<input type="text" placeholder="'+e+t+' Choice" class= "choice-'+e+'"><div class="delete-choice choice-'+e+'" onclick="deleteChoice(this); return false;">x</div>');$("input[name='addmore']").before(o)}function deleteChoice(e){var t=e.className.replace("delete-choice","").replace(" ","");$("."+t).remove()}