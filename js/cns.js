$(function(){
	$("#submit1").click(function(){
		if($("#submit1").val() === "0"){			
			// try connection and show connectionID
			// send request to firebase to get ID and show on screen
			// $(".foldText").text("FirebaseID = ");	// add connectionID
			$('.foldText').qrcode({width: 128,height: 128,text:"RRRRoselia"});
			$(".foldText2").show();
			$(".foldText").show();
			$("#submit1").text("Connect to iphone");
			$("#submit1").val("1");
			$("#submit2").hide();
			$("#submit3").show();
		}
		else{
			// check connection
			// if connection done/success, request firebase the corresponding password for a domain
			// get the response(input name and corresponding value)
			// send message to content-script to find the password field and input field and change the text
			Initialize();	
			
			// send notifications if connection success
			const options = {
				type:"basic",
				iconUrl:"../image/anfang.png",
				title:"Password Manager Notification",
				message:"Connection success, you can now import password from iphone to the webpage",
			};
			chrome.notifications.create(options);

			let params = {
		      active: true,
		      currentWindow: true
		    }
		    chrome.tabs.query(params,function(tabs){
		    	console.log("tabs = ",tabs)
		    	chrome.tabs.sendMessage(tabs[0].id,{favoriteband:"roselia"});
		    });
			// chrome.tabs.sendMessage({greeting: "hello"})
			console.log("message sent")
			// if connection failed
		}
	});
	$("#submit3").click(function(){
		Initialize();
	})
});

// back to initial states
function Initialize(){
	$("#submit3").hide();
	$("#submit2").show();
	$("#submit1").val("0");
	$("#submit1").text("Retrieve password");
	$('canvas').remove();
	$(".foldText").hide();
	$(".foldText2").hide();
}