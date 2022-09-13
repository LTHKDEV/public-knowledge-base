//frequent commands//

//leave terminal open with top running

//add my aliases
///aliases are not needed in ~/.bashrc because if a non interactive shell is running scripts then the script needs to contain any env variables being used.
vi ~/.aliases

#.aliases#

#navigation
alias lr="ls -ltr --color=auto"
alias lra="ls -ltra --color=auto"
alias lrd="ls -ltrd --color=auto"
alias cd..="cd .."
alias fscripts="cd /path/to/my/DBAScriptsFrequent"

///generally do not add these in an important env
#dot file editing - opens dot file for editiing and then runs file to apply changes
alias aliases="vim ~/.aliases && source ~/.aliases"
alias bashprofile="vim ~/.bash_profile && source ~/.bash_profile"
alias bashrc="vim ~/.bashrc && source ~/.bashrc"

///edit ~/.bash_profile to run ~/.aliases
///using source to run because if permission denied using source would be necessary, so running it with source to avoid possilbe permission denied issue
vi ~/.bash_profile

#run .aliases if it exists
if [ -f ~/.aliases ]; then
	source ~/.aliases
fi

//personalize vim options
///to make vim options permanent (i.e. set number or set nu [to turn off -> set nonu OR set nonumber]) have to add the options to the ~/.vimrc file
///this will turn on syntax highlighting -> syntax on
vi ~/.vimrc

set number
set tabstop=3 set shiftwidth=3
syntax on


//reverse i search
ctrl + R
then start typing in command you are searching for

//check instances running on server
ps -ef | grep pmon

//check oracle processes
ps -ef | grep ora

//check agent processes
ps -ef | grep java

//check directory space usage
du -sh *

//deleting trace fileSize
rm -rf *.trc
rm -rf *.trm


//sql pass command through to OS
///only works with OS commands, not aliases
SQL>!<OS command>
SQL>host <OS command>
ex:
SQL>!ls -ltr
SQL>host ls -ltr

//sql rerun previous query
SQL>/

// sql query formatting:
/// can use a10, a15, a30, etc
col <col_name> for a25

//sql run sql script from OS
SQL>@<filename>


//vi
(Normal Mode) O -> starts insert mode on the next line
(Normal Mode) DD -> deletes 1 line
shift + g -> end of file
ctrl + b -> page UP/back
ctrl + f -> page DOWN/forward
ctrl + d -> 1/2 page DOWN/forward
ctrl + u -> 1/2 page UP/back

///searching
/<search string> -> search file
N -> next occurrence
shift + N -> previous occurrence
To search for a whole word, start the search by pressing / or ?, type \< to mark the beginning of a word, enter the search pattern, type \> to mark the end of a word, and hit Enter to perform the search

///delete all lines
Press the Esc key to go to normal mode
Type %d and hit Enter to delete all the lines
:%d



//listner
lsnrctl
lsnrctl status
lsnrctl start
lsnrctl stop

//agent
agentstatus
agentstart
agentstop


//can copy entire putty session to clipboard
///*look up how to extend putty row max

//copying from TOAD for Oracle
to copy grid result with header ctrl+a then ctrl+insert (if no insert then insert is 0 on numpad with numlock off ex. ctrl+fn+0_from_numpad)

//get ip in linux
hostname -I
