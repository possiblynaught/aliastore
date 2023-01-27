# Aliastore

Designed to backup or restore custom user aliases in *~/.bashrc* to/from a CSV file.

## Use

The scripts are designed to be inherited as a git submodule or used independently after exporting a variable to point the scripts to a CSV file. Please see the sections below for inherited or standalone operation:

### Git submodule

You can use these scripts as a submodule in another repository. For instance, you could have a private repository to store your CSVs/configurations and point these scripts to your already saved, centralized aliases. To add this project as a submodule, run this from within another repository:

```bash
git submodule add https://github.com/possiblynaught/aliastore.git
```

Take a look at the *example\_submodule\_demo.sh* script for an example of integrating this into your existing automation/configuration. By exporting the *ALIASTORE\_CSV\_FILE* environment variables and calling *backup.sh* and *restore.sh*, you can automate the backup and restore process from another script.

### Standalone

The scripts can be used as standalone scripts by exporting an environment variable to indicate where to store/load data from. Here is the variable to export used by both the *backup.sh* and *restore.sh* scripts:

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

You can also hard-code the file path within the scripts themselves, see the sections at the top of the scripts containing the text: ***UNCOMMENT TO FORCE/OVERRIDE*** to set a persistent path variable.

### Note

The scripts assume that the user has aliases placed in *~/.bashrc* but you can re-target it to another rc file by editing the *$RC_FILE* variable in each script.

## TODO

- [ ] Prompt user to fix alias collisions
- [ ] Change to use *compgen -a* instead of a text flag in *~/.bashrc*