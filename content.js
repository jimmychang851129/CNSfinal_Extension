chrome.runtime.onMessage.addListener(setPassword);
function setPassword(msg,sender,resp){
	console.log("msg= ",msg);
	let data = document.getElementsByTagName('input');
	// not yet done: should get the list from firebase and key in corresponding value
	var FIND = 0;
	for(var i = 0 ; i < data.length ; i++){
		for(var j = 0 ; j < msg.length ; j++){
			if(data[i].type === msg[j][0]){
				FIND = 1;
				data[i].value = msg[j][1];
			}
		}
	}
	if(FIND === 0){
		alert("No password found");
	}
}