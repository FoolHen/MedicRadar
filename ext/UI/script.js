var i=0;

function addText(text) {
    i++;
    var listed = '<div id="item' + i + '"><label type="text" />' + text + '</div>';
    document.getElementById("list").innerHTML += listed;
}

function removeAll(){
    for (i; i > 0; i--) {
		document.getElementById('item'+i).remove();
    }
    i=0;
}

function hideUI(){
    var x = document.getElementsByTagName("BODY")[0];
    x.style.display = 'none';
}

function showUI(){
    var x = document.getElementsByTagName("BODY")[0];
    x.style.display = 'block';
}