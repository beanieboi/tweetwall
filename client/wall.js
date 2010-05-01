$(document).ready(function(){
	if(!("WebSocket" in window)) {
		alert("Sorry, the build of your browser does not support WebSockets. Please use latest Chrome or Webkit nightly");
		return;
	}

	ws = new WebSocket("ws://localhost:8080/");
	ws.onmessage = function(event) {
		tweet = eval("(" + event.data + ")");

		var tweet_div = $("<div id='"+tweet.id+"' class='tweet'><div class='tweet_text'>" + tweet.text + "</div><div id='tweet_author'>" + tweet.user.screen_name + "</div></div>");

		if (typeof tweet.images != "undefined") {
			jQuery.each(tweet.images, function() {
				tweet_div.append($("<img class='tweet_image' src='" + this + "'>"));
			});
		}

		if($('#tweets div.tweet').size() > 3) {
			$('#tweets div.tweet:last').slideDown(100, function() {
			          $(this).remove();
			        });
		}

		$('#tweets').prepend(tweet_div);

	};
});