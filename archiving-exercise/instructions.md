# Command line tools for archivists

prereqs: cd, pwd, ls, "what is bash", 

## Setup

(Get a tarball with junkfiles.py and anything else I need you to have. Unball(?) it. Get to the right directory.)

## Batch renaming files

You have volunteered to archive all of the data from all the Code4Lib conferences up to now. Thanks! Unfortunately, the data were put together by lots of really enthusiastic volunteers, who were not given a complete file naming convention ahead of time. (Let’s pretend there aren’t a ton of metadata experts in the Code4Lib community who would prevent that from happening.) Everything is in CSV (comma-separated values) format.

Navigate to the folder (SOME FOLDER) Look at what's in the folder (`ls`).

As you can see, there are about 100 files there, all from different years. They're kind of a mess. Renaming all of these files to all use the same naming convention would be tedious and take quite a while to do by hand, but we're going to clean this whole thing up with less than five minutes of work.

Now, there are a number of ways to do bulk edits of filenames on a CLI, including writing a script in Python or bash, or doing clever things with UNIX's find command. These are all totally valid. We’ll be using the `rename` command today.

### Rename

Rename uses something called "regular expressions," or as they are commonly referred to, "regex," to match on and change filenames. We are not going into regex in depth today, but we will use some simple regular expressions to do the work we need to do. `rename` uses the Perl flavor of regular expressions.

```rename -[flags] [regular expression] files```

There's one super important flag you should know about, `-n`. That allows you to look at what the command will do, without actually running the command, which can save you from a LOT of pain. It is SO GOOD.

### Regex

This is by no means a complete tutorial on regular expressions. Someone please put that together for next year's preconferences, though, OK? (I am not a regex witch or wizard.)
- `s/x/y/` - You may have seen this one around various tech chats. This takes out x and replaces it with y ("s" is for "substitute")
- `.` - this is a special character in regex and means "any character"
- `\` - this is the escape character, allowing you to use a special character as a literal (if you want to match on a period, use \.)
- `^` - means "not," in any case we'll use it today 
- `$` - means "the end of the string"
- `[]` - means character class
- `*` - means "match the preceding thing any number of times"
- `?` - means "the preceding thing is optional" (match 0 or 1 times)
- `+` - means "match one or more times"

#### Change .txt to .csv

`rename 's/\.txt$/.csv/' *.txt`

#### Change dashes to underscores

`rename 's/-/_/g' *`

#### Change plus signs to underscores

`rename 's/\+/_/g' *`

#### Change spaces to underscores

`rename 's/\ /_/g' *`

#### Make everything lowercase

This (apparently) won't work on a Mac, because Macs (appear to) have case-insensitive file naming. It works fine on 

`rename 's/([A-Z])/\L$1/g' *`

#### Put the year second in the filename

`rename -n 's/([a-z]*)_([a-z]*)_([0-9]*)/$1_$3_$2/' *`




