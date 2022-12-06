# SMS/MMS

A flutter plugin to open native messenger for SMS/MMS

This plugin primarily fulfils the requirement of opening native messaging app (*Google Messages*) on android & (*iMessage*) on iOS directly for sharing media.

### Fetures offered by plugin:

#### SMS:
  - Opening native messenger only with recipients 
  - Opening native messenger with recipients & message

#### MMS:  
  - Opening native messenger only with recipients 
  - Opening native messenger with recipients & message
  - Opening native messenger with recipients, message & file
  
_Code implementation:_  
<pre>
    <code>
        await SmsMms.send(
          recipients: recipientsList,
          message: messageController.text,
          filePath: filePath,
      );
    </code>
</pre>


