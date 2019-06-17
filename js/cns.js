$(function(){
    var register_id;
    const api_key = "AAAAKBzleVA:APA91bGqviLE2tKpJ3wpDrMVgz2vOtBus5JWh0H97stwknOr7s-bsiv9n7mWX1c16ZEN-H4e8SGkalhDx8TVjOCXQNsFsWPwbDO3uK-wT2IZB6Kg8cLaHMAxfVNflNgJIXxo1kPhH3Vt";
    var device_id;
    const sender_id = "172283492688";

	$("#submit1").click(function(){
		if($("#submit1").val() === "0"){			
			// try connection and show connectionID
			// send request to firebase to get ID and show on screen
			// $(".foldText").text("FirebaseID = ");	// add connectionID
			register();
			setTimeout(function(){			
				$(".foldText").show();
				$(".foldText2").show();
				$("#submit1").text("Connect to Iphone");
				$("#submit1").val("1");
				$("#submit2").hide();
				$("#submit3").show();},200)
		}
		else if($("#submit1").val() === "1"){
			// check connection
			// if connection done/success, request firebase the corresponding password for a domain
			// get the response(input name and corresponding value)
			// send message to content-script to find the password field and input field and change the text
			// Initialize();	
			
			// send current domain to firebase server 
			request();
			$("#submit1").text("Retrieve password");
			$('#submit1').val("2");
		}
		else if($('#submit1').val() === "2"){
			// let params = {
		 //      active: true,
		 //      currentWindow: true
		 //    };
		 //    let UserInfo = [['user','roselia'],['password','aiai']]		// assumption default value
		 //    chrome.tabs.query(params,function(tabs){
		 //    	console.log("tabs = ",tabs)
		 //    	chrome.tabs.sendMessage(tabs[0].id,UserInfo);
		 //    });
			// console.log("message sent")
			Initialize();
			// if connection failed
		}
		else{
			console.log("error occur invalid #submit1 number = ",$('#submit1').val());
		}
	});
	$("#submit3").click(function(){
		Initialize();
	})
	
	// register callback print register_id
	function registerCallback(regId) {
	    register_id = regId;
	    if(chrome.runtime.lastError){
	        console.log(chrome.runtime.lastError.message);
	    }
	    chrome.storage.local.set({"register_id": register_id});
	    console.log(register_id);
	}


	// register a id 
	function register(){
	    chrome.storage.local.get("register_id", function(result) {
	        if (result["register_id"]){
	            console.log(result["register_id"]);
	            register_id = result["register_id"];
	            $('canvas').remove();
	            $('.foldText').qrcode({width: 128, height: 128, text: register_id});
	        }
	        else{
	            chrome.gcm.register([sender_id], registerCallback);
	        }
	    });
	}

	// request the gcm to get data
	function request(){
	    var http = new XMLHttpRequest();
	    var url  = "https://android.googleapis.com/gcm/send";
	    var data = "registration_id=" + register_id + "&data.user=Roselia&data.password=aiai";
	    console.log(url);
	    console.log(data);
	    http.open('POST', url, true);
	    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded;charset=UTF-8');
	    http.setRequestHeader('Authorization', 'key='+api_key);
	    http.send(data);

	    chrome.tabs.query({'active': true, 'lastFocusedWindow': true}, function (tabs){
	        var qqurl = tabs[0].url;
	        console.log("url = ",qqurl);
	        $('canvas').remove();
	        $('.foldText').qrcode({width: 128, height: 128, text: qqurl});
	        $('foldText').show();
	        $('.foldText2').text("Scan the qrcode to request for password");
	        $('.foldText2').show();
	    });
	}
});

// back to initial states
function Initialize(){
	$("#submit3").hide();
	$("#submit2").show();
	$("#submit1").val("0");
	$("#submit1").text("Request for password");
	$('canvas').remove();
	$(".foldText").hide();
	$(".foldText2").hide();
}
