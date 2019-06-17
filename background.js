// Returns a new notification ID used in the notification.
function getNotificationId() {
  var id = Math.floor(Math.random() * 9007199254740992) + 1;
  return id.toString();
}

function messageReceived(message) {
  // A message is an object with a data property that
  // consists of key-value pairs.
  console.log("message received = ",message);
  // Concatenate all key-value pairs to form a display string.
  var messageString = [];
  for (var key in message.data) {
    messageString.push([key,message.data[key]])
  }
  console.log("Message received: ", messageString);

  // send notifications if connection success
  const options = {
    type:"basic",
    iconUrl:"image/anfang.png",
    title:"Password Manager Notification",
    message:"Connection success, you can now import password from iphone to the webpage",
  };
  chrome.notifications.create(options);
  let params = {
    active: true,
    currentWindow: true
  };
  // let UserInfo = [['user','roselia'],['password','aiai']]   // assumption default value
    chrome.tabs.query(params,function(tabs){
      console.log("tabs = ",tabs)
      chrome.tabs.sendMessage(tabs[0].id,messageString);
    });
    console.log("message sent")
}

var registerWindowCreated = false;

function firstTimeRegistration() {
  chrome.storage.local.get("registered", function(result) {
    // If already registered, bail out.
    if (result["registered"])
      return;

    registerWindowCreated = true;
    chrome.app.window.create(
      "register.html",
      {  width: 500,
         height: 400,
         frame: 'chrome'
      },
      function(appWin) {}
    );
  });
}

// Set up a listener for GCM message event.
chrome.gcm.onMessage.addListener(messageReceived);

// Set up listeners to trigger the first time registration.
// chrome.runtime.onInstalled.addListener(firstTimeRegistration);
// chrome.runtime.onStartup.addListener(firstTimeRegistration);
