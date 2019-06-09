# CNSfinal extension

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

## File

### index.html

popup page html, this show how the extension will look like when you click it

### css

css file for index.html

### js

javascript for index.html


### content.js

Manipulate Dom structure of current page/tab, this is how we key in the password for password field.


## Reference

[Chrome extension note](https://hackmd.io/@NCGXxkNfR2WNISqcwagt4Q/SJQ3nLrRE)