chrome.runtime.onMessage.addListener(setPassword);
function setPassword(msg,sender,resp){
	console.log("msg= ",msg);
	let data = document.getElementsByTagName('input');
	// not yet done: should get the list from firebase and key in corresponding value
	var FIND = 0;
	for(var i = 0 ; i < data.length ; i++){
		if(data[i].type === "password" || (data[i].type === "text" && data[i].name==="user")){
			FIND = 1;
			data[i].value = "Roselia";
		}
	}
	if(FIND === 0){
		alert("No password found");
	}
}