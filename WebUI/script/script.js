function addText(text) {
	var playerNames = text.split("|");
	playerNames = playerNames.filter(e => e !== "");

	removeAll();
	
	for (var j = 0; j < playerNames.length; j++) {
		var li = '<li class="nameBox" id="item' + j + '"><label>' + playerNames[j] + '</label></li>';
		$('#playerList').append(li);
	}
}

function removeAll(){
	$('#playerList').empty();
}

fontsize = function () {
	var size = $("#orangeRect").width() * 0.06;
	$('label').css('font-size', size);
};


$(window).resize(fontsize);
$(document).ready(fontsize);
