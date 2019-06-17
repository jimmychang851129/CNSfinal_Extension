$(function(){
    var register_id;
    const api_key = "AAAAY4y4ym8:APA91bGvRhyuiKkkzdzK0CkeqgRHPSpBoo4ycu0Tv66qNiG3mQBFIaU62P9vuvCXjRHRhkNUNg2AW4QvgP8Lt6QfP1IR4AKo503csyYVvGqA-EepB4Bv18ymJSTcWzh4sRV0yZNm35by"
        var device_id;
    const sender_id = "427562682991";

	$("#submit1").click(function(){
		if($("#submit1").val() === "0"){			
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
			Initialize();
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
	    console.log("register_id = ",register_id);
	}


	// register a id 
	function register(){
	    chrome.storage.local.get("register_id", function(result) {
	        if (result["register_id"]){
	            console.log(result["register_id"]);
	            register_id = result["register_id"];
	            console.log("register_id = ",register_id)
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
		 chrome.storage.local.get("register_id", function(result) {
	        if (result["register_id"]){
	            console.log(result["register_id"]);
	            register_id = result["register_id"];
	        }
	        else{
	            console.log("Error: register_id not found");
	        }
	    });
	    chrome.tabs.query({'active': true, 'currentWindow': true}, function (tabs){
	        var qqurl = tabs[0].url.split('//')[1].split('/')[0];
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
