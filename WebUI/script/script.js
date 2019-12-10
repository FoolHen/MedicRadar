function addMedics(medics) {
	if (typeof medics == 'object') {
		medics = Object.values(medics);
	}

	removeAllMedics();
	
	for (let j = 0; j < medics.length; j++) {
		let medic = medics[j];
		let li = '<li class="nameBox" id="item' + j + '"><label>' + medic.name + ' - ' + medic.distance + 'm</label></li>';
		let el = document.getElementById("playerList"); 
		el.innerHTML += li;
	}
}

function removeAllMedics(){
	let el = document.getElementById("playerList"); 
	el.innerHTML = '';
}

fontsize = function () {
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