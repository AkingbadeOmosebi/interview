# INITIAL SCRIPT

STDOUT="/dev/stdout"
LOG_FILE='$STDOUT'
LOG_MESSAGE='is the date, should log to $STDOUT'

# log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_message $LOG_MESSAGE


# REVIEW AND CORRECTION


# What this script is doing:

# It wants to log messages with timestamps.
# Think of it like a little notepad that automatically writes down what happened and when.

# It sets up a “log file.”

 STDOUT="/dev/stdout" > # basically means “write to the screen” (your terminal).

 LOG_FILE='$STDOUT' > # this was intended to use that screen location, but because of the quotes, it doesn’t actually work as intended.

# It creates a message.

 LOG_MESSAGE='is the date, should log to $STDOUT' > # this is the text the script wants to log.

 # IIt defines a function called "log_message".

# AA function is like a mini-program inside the script that you can call anytime.

# When you give it a message, it adds a timestamp in front (like “2025-10-16 01:36:00”) and tries to write it to the “log file.”

# t calls the function.

log_message $LOG_MESSAGE > # this is like saying: “Hey, take this message aand log it with the timestamp.” */



# CORRECTION

#!/bin/bash
STDOUT="/dev/stdout"
LOG_FILE="$STDOUT"  # Use double quotes to expand variable
LOG_MESSAGE="This is the date: $(date), should log to STDOUT"

# log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

log_message "$LOG_MESSAGE"



# What’s wrong / confusing:

# The script doesn’t actually log anywhere useful because of the $LOG_FILE vs $LOGFILE mismatch.

# The single quotes ' around $STDOUT prevent it from expanding — it stays literal $STDOUT instead of /dev/stdout.

# The message itself doesn’t dynamically show the current date — it’s just a static string.


## Analogy:

## Imagine you have a diary:

## You tell your diary: “Write today’s date and the message I give you.”

## But you accidentally hand it a blank piece of paper instead of opening the diary — nothing gets recorded.

## The fix is just opening the diary correctly and writing the message properly.