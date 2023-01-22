# SMS/MMS

A flutter plugin to open native messenger for SMS/MMS

This plugin primarily fulfils the requirement of opening native messaging app (*Google Messages*) on android & (*iMessage*) on iOS directly for sharing media.
### IOS Demo
https://user-images.githubusercontent.com/64741771/205976966-82406d92-fd50-4b10-a4bd-d2f121bd13aa.mov

### Android Demo
https://user-images.githubusercontent.com/64741771/205976824-2483f3b1-d946-430c-9b3e-dbf1054ee5b8.mov

## Android Native Side
Make sure to add this file file_paths.xml under (https://github.com/Manveer1999/flutter_sms_mms/blob/main/android/src/main/res/xml/file_paths.xml)

### Fetures offered by plugin:

#### SMS:
  - Opening native messenger only with recipients 
  - Opening native messenger with recipients & message

#### MMS:  
  - Opening native messenger only with recipients 
  - Opening native messenger with recipients & message
  - Opening native messenger with recipients, message & file
  
### Code implementation:
Implemention is quite easy, just call the function SmsMms.send()
<pre>
    <code>
        await SmsMms.send(
          recipients: recipientsList,
          message: messageController.text,
          filePath: filePath,
      );
    </code>
</pre>

##### recipients
- List of users to send message to. It contains list of string as eg. ["12345678", "1234"]
##### message
- Contains to body of the message to be sent
##### filePath
- Contains the path of the attachment to shared as MMS

### Issues
Some time on android, file does not get attached on first run

