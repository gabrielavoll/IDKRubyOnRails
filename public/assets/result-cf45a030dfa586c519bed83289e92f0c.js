

$(document).ready( function() {
	$('.learn_more_button').on("click", function(){
		$(".learn_more_box").addClass("hidden");
		$(this).parent().children(".learn_more_box").removeClass("hidden"); 
	});
});