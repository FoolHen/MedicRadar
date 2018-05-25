var num=0;

function addText(text) {
	var playerNames = text.split("|");
	playerNames = playerNames.filter(e => e !== "");
	var limit = Math.min(playerNames.length-1, 9);

	removeAll();
	
	for (var j = 0;j < limit; j++) {
		var listed = '<div class="nameBox" id="item' + (j+1) + '"><label>' + playerNames[j] + '</label></div>';
		document.getElementById("page").innerHTML += listed;
	}
	num = limit;
	fontsize();
}
function removeAll(){
	for (var i = num; i > 0; i--) {
		document.getElementById('item'+i).remove();
	}
	num = 0;
}
fontsize = function () {
	var size = $("#orangeRect").width() * 0.06;
	$('label').css('font-size', size);
};

$(window).resize(fontsize);
$(document).ready(fontsize);
