var num=0;

function addText(text) {
    var res = text.split("|");
    var limit = Math.min(res.length, 9);

    removeAll();
    
    for (var j = 0;j < limit; j++) {
        var listed = '<div id="item' + (j+1) + '"><label>' + res[j] + '</label></div>';
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
