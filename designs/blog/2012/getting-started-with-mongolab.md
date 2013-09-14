MongoLab provides MongoDB-as-a-Service on the Joyent Cloud (and on Cloud
providers) for the lowest latency between your Nodejitsu app and MongoDB.
500MB databases are available for free.  In a recent test, ping latency
averaged under 800 microseconds between our MongoLab Joyent servers and a
hosted jit.su server.  We have a web GUI for managing, searching, and editing
documents in MongoDB.  We also provide an authenticated [REST API][6] if you
need that.

## tl;dr

1. Visit http://mongolab.com and sign in / create a free account
2. Click _Create new_ in the _Databases_ section
3. Select JoyentCloud as the provider, with the Free plan (500 MB), us-east-1
datacenter
4. Populate the database name and at the bottom, the username and password
fields, then click _Create database_
5. In the database list, click on the new database to get to the detail page
6. Connection string is at the top of the page and should look like
`ds??????.mongolab.com:??????/databasename`.  Username and password are as you
entered them.
7. Connect and enjoy.  Contact support@mongolab.com with any questions

## Create a database

1. Visit <http://mongolab.com> and create an account or sign in if you have
one already.
2. Click _Create new_ in the _Databases_ section.  Alternatively, you can clone
an existing database if it's accessible on the Internet and you have a
username and password for it.

![Create][createnew]

## Select JoyentCloud, us-east-1

3. Select JoyentCloud as the provider, with the Free plan (0.5 GB), us-east-1
datacenter.
4. Populate the database name and at the bottom, the username and password
fields, then click _Create database_.

![Database Form][databaseform]

## Get your connection string

5. In the database list, click on the new database to get to the detail page.
6. Connection string is at the top of the page and should look like
`ds??????.mongolab.com:??????/databasename`.  Username and password are as you
entered them.
7. Connect and enjoy.  Contact support@mongolab.com with any questions.

## Thanks for using our service.

After your database is populated with at least one collection, you can run and
save queries, and edit documents directly in our UI.  That makes development
with MongoDB even easier.

![Database Detail][databasedetail]

## More MongoDB nodeknockout tutorials

* [Introduction to MongoDB][2]
* [Getting started with the Mongoose ODM for MongoDB][3]
* [Storing files with GridFS in MongoDB][4]
* [Geospatial indexes in MongoDB][5]

[1]: http://nodeknockout.com
[MongoLab]: http://www.mongolab.com
[createnew]:https://dl.dropbox.com/u/38052079/01-createnew.png
[databaseform]:https://dl.dropbox.com/u/38052079/02-databaseform.png
[databasedetail]:https://dl.dropbox.com/u/38052079/03-databasedetail.png

[2]: http://blog.nodeknockout.com/post/35214638964/a-basic-introduction-to-mongodb
[3]: http://blog.nodeknockout.com/post/34302423628/getting-started-with-mongoose
[4]: http://blog.nodeknockout.com/post/35215400231/a-primer-for-gridfs-using-the-mongo-db-driver
[5]: http://blog.nodeknockout.com/post/35215504793/the-wonderful-world-of-geospatial-indexes-in-mongodb
[6]: https://support.mongolab.com/entries/20433053-rest-api-for-mongodb
