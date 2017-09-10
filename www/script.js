var num=0;

function addText(text) {
    var res = text.split("|");
    removeAll();

    for (var j = 0;j < res.length; j++) {
        var listed = '<div id="item' + (j+1) + '"><label type="text" />' + res[j] + '</div>';
        document.getElementById("list").innerHTML += listed;
    }
    num = res.length;
}
function removeAll(){
    for (var i = num; i > 0; i--) {
        document.getElementById('item'+i).remove();
    }
    num = 0;
}
