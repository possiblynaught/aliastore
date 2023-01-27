# Aliastore

Designed to backup or restore custom user aliases in *~/.bashrc* to/from a CSV file.

## Use

The scripts are designed to be inherited as a git submodule or used independently after exporting a variable to point the scripts to a CSV file. They operate by looking for two bash comments in a bash rc file and operating on everything between the comments. By default, the script operates on *~/.bashrc* plus uses "*#### Start Custom*" and "*#### End Custom*" as the default block indicators. If the block start/end indicators don't already exist while restoring, the script will automatically create them while populating the custom aliases. An alias block created or backed up by this script will look like this at the end of the *~/.bashrc* file:

```bash
#### Start Custom
alias la='ls -a'
alias ls='ls --color=auto'
#### End Custom
```

The restore script will automatically overwrite existing alias blocks and the backup script will warn the user of any aliases with the same name different functions between the CSV file and the alias block. 

Please see the sections below for inherited or standalone script operation:

### Git submodule

You can use these scripts as a submodule in another repository. For instance, you could have a private repository to store your CSVs/configurations and point these scripts to your already saved, centralized aliases. To add this project as a submodule, run this from within another repository:

```bash
git submodule add https://github.com/possiblynaught/aliastore.git
```

Take a look at the *example\_submodule\_demo.sh* script for an example of integrating this into your existing automation/configuration. By exporting the *ALIASTORE\_CSV\_FILE* environment variables and calling *backup.sh* and *restore.sh*, you can automate the backup and restore process from another script.

### Standalone

The scripts can be used as standalone scripts by exporting an environment variable to indicate where to store/load CSV data. Here is the variable to export used by both the *backup.sh* and *restore.sh* scripts:

```bash
export ALIASTORE_CSV_FILE=/the/save/file.csv
```

After setting the variable, you can enter the *aliastore* directory, make the scripts executable, and run them:

```bash
chmod +x backup.sh
./backup.sh
```

or

```bash
chmod +x restore.sh
./restore.sh
```

Once you are done, you can unset the variable until you need to run the scripts in the future:

```bash
unset REPOSTORE_CSV_FILE
```

You can also hard-code the file path within the scripts themselves, see the sections at the top of the scripts containing the text: *### Force override of environmental variable for csv file* to set a persistent path variable that can override any environmental vars.

### Optional Overrides

Optionally, you can also override the default script definitions for where the rc file is located and the text comment flags to look for the custom block of aliases. By default, the *~/.bashrc* file is the default rc file but exporting the *ALIASTORE\_RC\_FILE* variable to point at another file will override the default in the script. Additionally, you can use different start/end indicators by exporting the *ALIASTORE\_START\_FLAG* and *ALIASTORE\_END\_FLAG* variables. Note that these act as bash comments on a line before/after the block of aliases, make sure any custom name for these start/end vars begins with a "#" so no bash errors are thrown. Here is what that would look like:

```bash
export ALIASTORE_RC_FILE=/different/bashrc/file
export ALIASTORE_START_FLAG="# New beginning indicator"
export ALIASTORE_END_FLAG="# New end indicator"
```

## TODO

- [ ] Prompt user to fix alias collisions instead of just notifying
- [ ] Change to use *compgen -a* instead of a text flag in *~/.bashrc*