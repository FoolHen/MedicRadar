function addMedics(medics) {
	// Just in case we make sure the medics param is an array, not an object. This happens when a lua table is empty, as the JSON encoder doesn't 
	// know if the table is supposed to be an array or an object.
	if (typeof medics == 'object') {
		medics = Object.values(medics);
	}

	// Clear previous elements first.
	removeAllMedics();
	
	// Now we want to create an element for each medic in the array.
	for (let j = 0; j < medics.length; j++) {
		let medic = medics[j];
		let li = '<li class="nameBox" id="item' + j + '"><label>' + medic.name + ' - ' + medic.distance + 'm</label></li>';
		// Attach it to the playerList element.
		let el = document.getElementById("playerList"); 
		el.innerHTML += li;
	}
}

// Clears all player info elements.
function removeAllMedics(){
	let el = document.getElementById("playerList"); 
	el.innerHTML = '';
}

fontsize = function () {
	// As the vanilla UI stops resizing at 720p we can't use percentages or vmin for font size, so we calculate it with the width of the orange rectangle.
	// Check style.css to see how the UI mimics the fixed aspect ratio of the vanilla UI.
	let el = document.getElementById("orangeRect"); 
	let size = el.clientWidth * 0.06;

	let pageEl = document.getElementById("page"); 
	pageEl.style.fontSize = size + 'px';
};


window.onresize = function(event) {
	fontsize();
};

window.onload = function(event) {
	fontsize();
};