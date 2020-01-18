# A Password Manager based on Fingerprint Authentication

## Introduction

We have designed a password manager with high portability along with high security level. Moreover, we do not have a trusted third party in our system in that all the passwords are stored in users' mobile phone.

We utilize user fingerprint, QRcode, APIs of IOS system, and Firebase server to construct a password transmission protocol.

Our password manager outperform lots of current password manager in used

1. Even users would like to use other computer to login, **the users will only need to bring their mobile phone and install the browser extension on the browser for our password manager to work.**

2. Since **passwords are stored locally in users' mobile phone**, we do not need to trust any third party server. Moreover, we utilize user fingerprint for authentication. As long as the users' mobile phones are secure, our password manager may maintain high security level.

## Workflow Illustration

### ID Registration

![](https://i.imgur.com/oTnjEZR.png)

### system workflow

![](https://i.imgur.com/hI6m2Qx.png)


## Features
1. user-friendly
    - user only have to install the app for mobile phone, browser extension on the PC. The whole password filled in process only require users to scan two QRcodes shown by the browser extension

2. High protability
    - When users would like to login in another devices, they would only need to install the browser extension and scan the qrcode with their mobile phone in that all the passwords are stored in mobile phone.


3. High Security level
    - The password transferred from mobile phone to webpages is protected by TLS protocol and One-time pad, and one-time pad is proved to be perfectly secure
    - The key delivery for One-time pad is through the QR code scanning process, and attackers can hardly notice the OTP key.

## Demonstration


## workflow

1. The user gets to the login page and clicks the password manager extension.

2. The extension have two functionalities: retriving password from iphone or key in new password and save it to iphone(not sure if this is required).

3. The user click on the retrive password button, the extension should connect to the firebase server and retrieve an ID.

4. The extension shows the ID on the popup page(index.html)

5. After the user keyed in the ID on his iphone click on the connect to iphone button

6. the extension will then request the firebase to get the ID of the iphone

7. If all set, the extension will show an notification of connection success or will show connection failed otherwise(not retrieving the ID from firebase)

8. If success, the extension will trigger an event(tab.query) to notify the content.js, content.js will then query firebase the corresponding password or username for this website.

9. If successfully queried, filled in the response to the specific input field, if no matched input field(for instance, no input field in the page), send an alert and notify the extension(cns.js)




## Code structure

### ios

code for the iphone
- User password Storage/ management
- QRCode scanning
- send message to firebase server

### Extension

code for the browser extension.
Fuctionalities of browser extension
- Registration ID generation
- OTP key generation, 
- QRCode generation/manifest
- Receive message from Firebase server
- filled in the password in corresponding field on the webpage

#### index.html

popup page html, this show how the extension will look like when you click it

#### css

css file for index.html

#### js

javascript for index.html


#### content.js

Manipulate Dom structure of current page/tab, this is how we key in the password for password field.


## Reference

[Chrome extension note](https://hackmd.io/@NCGXxkNfR2WNISqcwagt4Q/SJQ3nLrRE)
