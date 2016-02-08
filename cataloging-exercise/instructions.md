# Cataloging on the Command Line

Catalogers can profit from many uses of the command line, primarily through batch processing metadata files to make many small changes or convert from one format to another. In this exercise, we'll learn how to run scripts on the command line, pass information to those scripts (such as what file we want them to process), and "redirect" output to a file. Ready? Let's go!

## Running a Script

Running a script is similar to using any command or executing a program, you simply type the full path to the script and press Enter. But this becomes incredibly tedious; we don't want to have to type out a long path to our current directory every time we run a script. Instead, we use the period (".") shorthand which refers to our current location. So we can run the "script.sh" in this folder like so:

```sh
> ./script.sh
```

Hey hey, we did it! Since "." refers to the current directory, the above is equivalent to "/path/to/where/you/downloaded/cataloging-exercise/script.sh".

That's most of what you need to know about running scripts, but there are some nuances. The "non-exe-script.sh" has the exact same text as "script.sh", but what happens when we try to run it? We get some kind of "permission denied" error. Why is that? Well, let's check permissions:

```sh
> ls -l
```

We're using the familiar `ls` command but have added an option to it that make its output more verbose. There's quite a bit of information here, but the most important part is at the beginning of each line where the permissions string "-rw-r--r--" precedes "non-exe-script.sh" while "script.sh" has the different permissions "-rwxr-xr-x". We won't go into exactly what these mean, but the "x" in that string refers to "eXecutable" and our "non-exe-script" isn't allowed to be run by the shell. We can change its permissions with the `chmod` (CHange MODe) command:

```sh
> chmod +x non-exe-script.sh
```

Now what happens when you try to run "non-exe.script.sh"? Does it work? What do you think you'd have to do to make it _not_ executable any longer?

## Passing Information to a Script & "Flags"

OK, we know to run a script we need to a) refer to its location, and b) make sure it's executable. So far, so good. But what if we want to pass information to a script? For instance, what if a script could run on different files or operate differently depending on the options we specify, much like how `ls -l` is different from plain ol' `ls`?

The standard way to pass information on the command line is by "flags". We've actually already seen several examples, because these flags are merely the hyphenated letters we've used previously. But let's dive into a cataloging example using a wonderful script in this folder: MARCgrep.pl. MARCgrep is a tool for searching over MARC files and counting up how many records match a provided pattern, or have a certain field or subfield. It's syntax is like so:

- The "-e" flag is followed by a string like "field,indicator1,indicator2,subfield,value" such as "245,,,,fox" (matches any record with "fox" in its 245 title field)
- The "-c" flag, if present, means that the script only counts how many records match the pattern, otherwise the script spits out the full record
- The "-f" flag can be followed by a comma-separated list of fields to print instead of the full record, e.g. we could use "245,100" to print just the title and author fields.

There's a full example below; what do you expect it will produce? Give it a try!

```sh
> ./MARCgrep.pl -e '245,,,,fox' -f '245' example.mrc
```

Just to practice passing different information to the script, try to answer the following questions using the provided "example.mrc" set of records:

- How many records have "turkey" in their 245 title field?
- What's the title of the record where the author's (100 field) last name is Rodriguez?
- How many books have 651 fields?
- Is Shakespeare more commonly the author (100) or the subject (600) in these records?
- What are the other subjects of the book where Gentrification - California - San Francisco is a subject (650)?

Try a few more queries on your own, with different combinations of "-e", "-f", and "-c" flags.

There's also a second way to pass information, by _positional_ parameters. Remember when we ran `cmod +x non-exe-script.sh` up above? How did the script know that our first parameter "+x" was an option and our second one was a file? Commands might expect certain types of information in certain positions, in the case of the `chmod` command the syntax is always: chmod, followed by a (required) option defining the permissions to change, followed by a (required) file. Try reversing the two arguments:

```sh
> chmod non-exe-script.sh +x
```

What happened? Did your computer explode? Hopefully not. Most likely, the chmod command complained that "non-exe-script.sh" was an "invalid mode" because it was expecting the _mode_ (translation: permissions) first and the file second, not the other way around. We just have to remember the order of positional arguments. For that reason, they're not as convenient or explicit as flags, which tend to make it obvious what's going on and don't care about order at all.

## Output Redirection

@TODO ERIC write an actual exercise here!!!

## Piping ?

@TODO ERIC write something here!!!

(is this worth going into? could see some cool applications where script output is piped through `sed` or similar)

## Exercise One: Batch process a MRC file

Included in this folder is a Python script named "pm-script.py". It uses the incredibly popular "pymarc" Python module to batch process MARC records. The script's syntax is:

```sh
> ./pm-script.py --limit 100 input.mrc output.mrc
```

where the number after the optional "limit" flag is the maximum number of MARC records to process, the first first passed in the input, and the second file passed is where the output will be written to. The command also accepts an optional "--verbose" flag which causes it to print information about what it's doing. Try running the script a few times, at first with a small limit but then process the full file. What is the script doing? Can you write its output to the same file multiple times and if so what happens to the prior output? Can you run it on its own output and if so what does that accomplish?

You may be thinking "but my ILS client can already do this"! And that's true in a number of cases, the operations you perform on the command line may be achievable elsewhere. Still, there's often greater flexibility in command line scripts, which can utilize complex logic that your ILS may not be able to, and these scripts can be combined to perform several operations in a row quickly. Try running the "batch-analysis.sh" script; what does it do? Remember you can run `cat batch-analysis.sh` to read the text of the script, or open it up in a command-line text editor like `nano` or `vim`.

**Bonus Problem**: the "batch-analysis.sh" script writes out a plain text file. Try mimicking the script's use of the stream editor `sed` to delete URLs beginning with a certain pattern (put the pattern after the "^" in the original `sed` command and delete the dollar sign).

## Exercise Two: Use "help" to figure it out

We learned earlier to pass information to a script using a `--limit` flag and positional parameters. That's all well and good, but what if we're given a script or program and we're not sure what flags it accepts or where the positional parameters go? We can often search the web for answers, and that's a fine approach, but one of the nicest things about the command line is how documentation is often right at our fingertips.

@TODO ERIC write the exercise-two script!!!

In this folder there's a "exercise-two.py" script. Find out what it does and run it successfully on our sample MRC file. Unsure where to start? There's a common convention whereby the flag `--help` or its shorthand `-h` will provide information. Try getting help with and then using the script.

Let's return to MARCgrep.pl too; what if we want to find out how many records _do not_ have a certain field? Let's use MARCgrep's help to find out!

## Notes

- MARCgrep http://en.pusc.it/bib/MARCgrep
- pymarc https://github.com/edsu/pymarc
- Internet Archive Open Library Data https://archive.org/details/ol_data
