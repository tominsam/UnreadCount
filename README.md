Scripts for counting in unread items in online services. Pretty much a collection of hacks, frankly,
I'm putting them here in case anyone cares.

You'll need a config file - copy `config.template.yaml` and fill it in.

I run these scripts from a crontab as follows:

    0 * * * * ~/Github/UnreadCount/doit

The `doit` script counts things once an hour, then copies the output files into my webserver tree
where my sparkline generator `index.html` can load them and generate pretty graphs. It's crude, but
works for me and doesn't need a database. I seem to be rabidly anti-database this year.

## Summary of scripts:

### instapaper.rb

Awful, awful, instapaper unread item counter. Screen-scrapes the site so it'll probably be fragile.

### imap.rb

This one is actually a decent technique, though it's not battle-hardened yet. Just counts unread items in the
IMAP inbox of a server you pick, though it can also just count unread items. Personally, I archive things I've dealt with,
and my inbox is a list of 'things I have yet to do', so I like it counting everything.

### reader.rb

Google reader unread item counting. Uses an actual API, but it's a slightly scary reverse-engineered API. We'll see.

### unread.rb

this is the library file - just a collection of general utilities that all the counters like. Logging, config
file reading, etc.

## Web front-ends

There's a couple of web front-ends for displaying the sparkline graphs in the `web` folder, a PHP one and a JavaScript
one. I'm using both - the PHP one is faster and probably less finicky to make work, and it doesn't need the unread
count text files to be in your web server directory. But the JavaScript one doesn't require any server-side smarts at
all - you need a cronjob that can run the monitor scripts and copy the unread count files into your web server
tree. Use or adapt the one that makes sense to you.

## TODO

* generate the google graph urls directly into the HTML rather than just writing the data, it'll be lots faster

* more scripts to track more unread things.

* The IMAP counter should be able to count unread items in folders as well, I guess. Does anyone care?


