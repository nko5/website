_This is the 7th in a series of posts leading up to [Node.js Knockout][] on
using [Nodemailer][].  This post was written by [Node Knockout judge][] and
[Nodemailer][] creator Andris Reinman._

[Node.js Knockout]: http://nodeknockout.com
[Nodemailer]: https://github.com/andris9/Nodemailer
[Node Knockout judge]: http://nodeknockout.com/people/5087188cb1bc4903200000a9

## tl;dr — How to send an e-mail using Nodemailer

Install Nodemailer

    > npm install nodemailer

Include the module in your script and create a reusable transport object

    var nodemailer = require("nodemailer");

    var smtpTransport = nodemailer.createTransport("SMTP",{
       service: "Gmail",
       auth: {
           user: "gmail.user@gmail.com",
           pass: "gmailpass"
       }
    });

Send an e-mail using the connection object

    smtpTransport.sendMail({
       from: "My Name <me@example.com>", // sender address
       to: "Your Name <you@example.com>", // comma separated list of receivers
       subject: "Hello ✔", // Subject line
       text: "Hello world ✔" // plaintext body
    }, function(error, response){
       if(error){
           console.log(error);
       }else{
           console.log("Message sent: " + response.message);
       }
    });

Send another e-mail without caring about the outcome (or add the callback function as well, like in the previous code block, if you do care)

    smtpTransport.sendMail({
       from: "My Name <me@example.com>", // sender address
       to: "Your Name <you@example.com>", // comma separated list of receivers
       subject: "Hello ✔", // Subject line
       text: "Hello world ✔" // plaintext body
    });

For additional details see [Nodemailer documentation](https://github.com/andris9/Nodemailer) or read through this article.

## Super brief introduction to e-mail technologies

There are several ways to send an e-mail but in the end it all comes down to the SMTP protocol ([Simple Mail Transfer Protocol](http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol)), since this is the method how e-mails are actually transferred in the interwebs. There have been some other propositions as well in the past, like ISO standardized X.400 for example but these never took off and thus don't really matter for most.

The reason why you don't just open a TCP connection to the recipients incoming SMTP server (the one that is found from the domains DNS MX record and listening on port 25), transmit the message and be done with it, is that in this way, most probably, your message ends up in the junk folder or gets lost entirely - for one, you are not a trusted sender, your sending volumes are way too low (what an irony). This behaviour is also not optimal, as your application would have to handle e-mail bounces, errors, greylisting etc. The better way instead is to turn to your Mail Submission Agent (MSA), which also speaks SMTP and for an exchange of your credentials, happily queues your message for delivery by a relaying Mail Transfer Agent (MTA), which in turn, also speaks SMTP. Often MSA and MTA are one and the same but in theory they are meant to perform somewhat different tasks.

SMTP is a textual protocol and looks a bit like this:

    CLIENT: <initiates connection to the server>
    SERVER: 220 bob the mailcat listening
    CLIENT: HELO joe.the.sender
    SERVER: 250 Hello, joe.the.sender, nice to meet you!
    CLIENT: MAIL FROM:<me@example.com>
    SERVER: 250 Ok, proceed with recipients
    ...

> The numbers returned from the server are status codes, anything equal or above 400 is an error (HTTP anyone?)

While SMTP defines the transport of the envelope (from the sender's computer to the recipients inboxes), the contents of the envelope is a completely different thing. Actually the two are so unrelated, you can set whatever you want to as the message contents (you can spoof “from” and “to” addresses in the mail header, you can set a future or prehistoric date for the message, you can use strange byte sequences or use an invalid format etc.) and it still gets delivered. Depending on the MSA, some of the data might be corrected though (eg. the prehistoric date of yours might be adjusted to a more recent value) but not all of it.

It's exactly as with regular mail - you have an envelope that says where the letter is supposed end up and then you have the envelope contents that can contain a valid letter, addressed to the same person labeled on the envelope; or some money without an explanation; or some barb wire; or instead a letter addressed someone totally unrelated from the person on the label of the envelope. If you don't have the envelope you can never be sure just based on the included letter from where the message originates and to whom it was sent.

Thats why when you look at a spam mail you often see that the recipient name and address fields are blank or invalid - the e-mail client program takes this information from the message contents and not from the envelope. Luckily most servers prepend some of the envelope information also to the mail header, so if you look at the raw source of the message, the first line, “Delivered-To” says which actual address was the final receiver. With several mail accounts ending up in the same e-mail client box, you might not be always able to tell it by yourself. That is also how BCC works - the name is on the envelope but not in the message.

The most simple e-mail message only consists of header and ascii content

    From: me@example.com
    To: you@example.com
    Subject: Hello

    How are you doing?

> If you've ever done HTTP, then the structure should seem familiar. There's a header block and after two consecutive line breaks (NB! all line breaks in the interwebs protocols use the form &lt;CR&gt;&lt;LF&gt; (eg. the “windows style”) and not the &lt;LF&gt; (the “unix style”) form) comes the body of the message.

Nontrivial E-mail messages (the ones that want to use non-ascii characters or attachments or almost any other feature) are formatted by [MIME](http://en.wikipedia.org/wiki/MIME) which stands for Multipurpose Internet Mail Extensions. You can include multiple “views” of the same data for the message (ie. HTML view and plaintext view), add binary attachments, use different character sets and so on but eventually it is all compiled to a single ascii-only file before it is being sent as the e-mail. The compiled raw source was meant to be human readable on ancient 80 column terminals but with multipart messages (attachments, different “views” etc), it is not a pleasant exercise to browse through - all “extensions” are added on top of the original plain format, making up an onion-like structure. For example one horror child of such extending is the way to support long unicode filenames etc. for attachments ([RFC2231](http://tools.ietf.org/html/rfc2231)) that uses urlencoding instead of mime encoding.

While most of the strings in e-mail headers are encoded in [MIME encoded-word](http://en.wikipedia.org/wiki/MIME#Encoded-Word), like the following

    Subject: =?us-ascii?Q?This_is_even_more_***fun***_isn't_it!?=

Then here's an excerpt from the RFC2231 for splitting long header values:

    Content-Type: application/x-stuff
       title*0*=us-ascii'en'This%20is%20even%20more%20
       title*1*=%2A%2A%2Afun%2A%2A%2A%20
       title*2="isn't it!"

No, it is not fun.

![Y U NO USE SAME ENCODINGS FOR EVERYTHINGZ?](http://cdn.memegenerator.net/instances/400x/28908667.jpg)

## E-mail modules

To keep you away from the tedious task of mingling together standard compliant e-mail messages that would go through the wire, enter e-mail sending libraries. There are some for every programming language and for Node.js, there’s [Nodemailer](https://github.com/andris9/Nodemailer) by yours truly or [emailjs](https://github.com/eleith/emailjs) by eleith. These, of course, are not the only options, there used to be (now deprecated) [node_mailer](https://github.com/Marak/node_mailer) by Marak Squires and there still is [pony](https://github.com/substack/node-pony) by substack, there’s probably even more but for feature completeness I would definitely suggest using either Nodemailer or emailjs. As the author of Nodemailer I'm not going to describe the other modules but these are still worth checking out.

## Installing Nodemailer

Installing Nodemailer follows the common path - you can install it from npm. Add a dependency to your package.json and run `npm install`

package.json contents:

    ...
    "dependencies": {
       "nodemailer": "0.3.29"
    },
    ...

**NB!** If you don't have a package file yet, you can create one automatically by running `npm init`.

Now update your installation by running in the same directory the package.json resides.

    npm install

> If you are on Windows, you are going to see some error messages flying through while installing but this is normal and doesn't affect how the module is going to work in the end. Nodemailer tries to drag [iconv module](https://github.com/bnoordhuis/node-iconv) to the party as an optional dependency and iconv needs compiling. The iconv module isn't even used, since all the output and input strings for Nodemailer are always in UTF-8. I just haven't found a good way to automatically exclude the iconv module since the other modules that share the same codebase (eg. [MailParser](https://github.com/andris9/mailparser)) do need it.

And as the last part of the installation equation, include Nodemailer in your script file

    var nodemailer = require("nodemailer");

## Selecting mail transport method

While SMTP makes up the barebones of e-mail messaging, you don't actually have to use it directly if your MSA accepts something else, for example HTTP POST request with e-mail file etc. Nodemailer includes 3 different mail transports and if this doesn't suit you, you are welcomed to add your own.

 1. **SMTP** (obviously)
 2. **sendmail** to stream message contents to the stdin of `sendmail` command
 3. **SES** to post the message contents to Amazon SES REST API endpoint (SES also exposes SMTP endpoint but the used credentials are different in this case, see SES docs for details)

In this article we only look at using SMTP as it is the most important of them all.

## Setting up SMTP

To use SMTP you need to have access to a MSA server. If you have a Gmail or Google Apps account, you can use Gmail SMTP for this but you can't ride it far as there are strict usage limits (about 100 emails per day, unless you have a Google Apps Business account that has [higher limits](https://support.google.com/a/bin/answer.py?hl=en&answer=166852)), besides you can only send mail *from* the same user you are authenticated as, you can't change it to something else (actually you can change the address but it is displayed as a nasty “via authenticated.user@gmail.com” address, not good for your business if you want it to show just “billing@mycompany.com” instead). If you need to go any further, consider using [Sendgrid](http://sendgrid.com/) or [Postmark](http://postmarkapp.com/) or [Mailgun](http://www.mailgun.com/) or Amazon SES or any other professional message delivery service. There's a great discussion in Quora about the [reasons behind pricing](http://www.quora.com/Why-are-Mailgun-and-Postmark-so-much-more-expensive-than-Sendgrid-and-AWS-SES) of these services. If you don't want to send hundreds of millions messages, it is usually more feasible to pay one of the providers than building your own e-mail infrastructure. But getting started is totally free - you can use Gmail as a starting point and move on to a free trial or a developer account of another service before you need to pay a cent.

Lets say that for a starters you're going to use Gmail as the SMTP service. Setting up Nodemailer is a piece of cake in this case, you just need to have your username and password available:

    var smtpTransport = nodemailer.createTransport("SMTP",{
       service: "Gmail",
       auth: {
           user: "gmail.user@gmail.com",
           pass: "gmailpass"
       }
    });

And that's it, you now have a working wire for transmitting e-mails.

**NB!** If your mail configuration needs go beyond Gmail, you can find the full spectre of connection settings from the [Nodemailer documentation](https://github.com/andris9/Nodemailer#setting-up-a-transport-method).

> The problem with SMTP is that you need to have plaintext passwords available somewhere for the app. In case of Gmail there are actually several other options as well. If you use 2 factor authentication, then you can generate application specific password for your mailing app without compromising your real password. There's also a way to use OAuth1.0 and OAuth2.0 tokens with Gmail if you want to skip using passwords at all. See [Nodemailer documentation](https://github.com/andris9/Nodemailer#smtp-xoauth-and-token-generation) for details.

## Sending an e-mail

Now that we have the working wire, we can start sending e-mails. The simplest form of e-mail requires sender address, recipients address, subject line and message text which can be formatted like this:

    var mailOptions = {
       from: "me@example.com", // sender address
       to: "you@example.com", // list of receivers
       subject: "Hello ✔", // Subject line
       text: "Hello world ✔" // plaintext body
    }

If the e-mail structure has been composed, we can send the mail using the “transport wire” defined earlier

    smtpTransport.sendMail(mailOptions, function(error, response){
       if(error){
           console.log(error);
       }else{
           console.log("Message sent: " + response.message);
       }
    });

> Nodemailer transport object accepts a large number of messages to be sent at once, you don't have to wait for the first message to be delivered before you can proceed to the following. Only a limited count of connections are opened to the SMTP server (Nodemailer uses built-in connection pooling) at once and messages are queued automatically for delivery. Thus you can initiate `sendMail` just as well from a `for` loop, no need for a complex async setup or a callback hell.

    for(var i=0; i<mailArray.length; i++){
       smtpTransport.sendMail(mailArray[i]);
    }

### Address formatting

Usually you want to include the name of the sender or receiver in addition to the plain address, or sometimes you want to send the e-mail to not just one but several recipients. Nodemailer recipient fields (“to”, “cc”, “bcc”) accept comma separated addresses for multiple recipients and the name can be formatted as well (remeber to enclose the name in double quotes if it contains a comma).

    ...,
    from: "\"Name, User\" <user.name@gmail.com>",
    to: "Receiver Name <receiver@gmail.com>, plain@example.com, \"Name, Another\" <another@gmail.com>"
    ...

And as with any other field, unicode is allowed - you can use non-ascii characters both for the names and for the domains, unicode e-mail domains are converted to the punycode form automatically.

## Advanced options

Nodemailer supports a lot of advanced options, like DKIM signing or OAuth2.0 token generation and we are not going to cover all of these here, see [Nodemailer docs](https://github.com/andris9/Nodemailer) instead for all the details about these features.

### Using HTML and plaintext views

Usually the e-mail contains either HTML view (usually the default), plain text view or both. It is a good practice to include plaintext view in addition to the HTML view, so the less-able mail clients could fall back. Nodemailer can generate the plaintext view automatically, based on the HTML view but you can create it yourself if you want to (or skip it altogether, as only plaintext capable clients are pretty rare nowadays).

You can use both html and text views by specifying according properties of the e-mail object.

    ...,
    text: "plaintext contents",
    html: "<p>HTML contents</p>",
    ...

> Keep in mind that one of the main differences between text and html views is that newlines are ignored in the html view but not in the plaintext view when rendering the contents.

You can generate the text view automatically when using `generateTextFromHTML` property

    ...,
    html: "<p>HTML contents</p>",
    generateTextFromHTML: true,
    ...

Or if you don't want to include the text contents at all, use only html property

    ...,
    html: "<p>HTML contents</p>",
    ...

> Just whatever you do, do not use a plaintext view that only states “Your e-mail client is not capable of displaying this e-mail” - a lot of e-mail clients use the plaintext part (if it exists) as the preview for the message and html part for the actual viewing.

### Adding attachments

Attachments are defined as an array of attached files. You can use a variety of data sources for the attachments (files on disk, strings, buffers, streams, even web urls) and for these examples we are using files on disk. See [Nodemailer documentation](https://github.com/andris9/Nodemailer#attachment-fields) for the other options.

The most simple form of attachments are file paths on disk. Attachment filename and content type are derived automatically in this case (although you can override these values if you want to).

    ...,
    attachments: [
       {filePath: __dirname + "/attachment1.txt"},
       {filePath: __dirname + "/attachment2.txt"}
    ],
    ...

When using images as attachments, you can point to these images as embedded files for the HTML view. You need to define unique `cid` value for the attachment and use it as an URL.

    ...,
    html: "<p>Embedded image: <img src='cid:image1'/></p>",
    attachments:[
       {filePath: __dirname + "/image1.jpg", cid: "image1"}
    ],
    ...

## In conclusion

Using an e-mail library like Nodemailer makes your life so much easier if you want to send an e-mail with Node.js. Sure, you can compose the message by yourself and transmit it using the standard Node.js `net` module (and if you're really interested how the e-mail system works, then this is exactly the way you're going to do it) but most probably you just need to send an e-mail to your customer and you don't really care how it is delivered, as long as it makes it through and displays as intended.

If you want to bring your e-mail related application to the next level, you could also start receiving and parsing e-mail in addition to sending it. For creating your own SMTP MX server for accepting e-mail from the interwebs, you can use simpler [SimpleSMTP](https://github.com/andris9/simplesmtp#smtp-server) by yours truly or full featured [Haraka](http://haraka.github.com/) by baudehlo which is able to fight against spam as well. If you do not want to manage message exchange server by yourself but to use IMAP for connecting to an existing one, you can use [node-imap](https://github.com/mscdex/node-imap) by mscdex or [inbox](https://github.com/andris9/inbox). Once you have received the e-mail (either through SMTP or IMAP), you can parse the raw source into a structurized object wih [MailParser](https://github.com/andris9/mailparser). I have also created a helper module [mailuploader](https://github.com/andris9/mailuploader) to parse an e-mail raw source and post the parsed object to a HTTP address as a regular *multipart/form-data* upload, so even a PHP script could easily handle it.

I hope that by reading this article you found out how easy it is to send e-mails using Nodemailer. And if you ever run into trouble with it, then you know where you can [file an issue](https://github.com/andris9/Nodemailer/issues).