#!/bin/bash
#Number guessing game script

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

echo -e "\n~~Number Guessing Game~~"
#generate number
GENERATED_NUMBER=$((1 + $RANDOM % 1000 ))
#read username
echo -e "\nEnter your username:"
read USERNAME
USERNAME_ID=$($PSQL "SELECT username_id from usernames where username='$USERNAME'")
#if no found
if [[ -z $USERNAME_ID ]]
then
  #add to database
  ADD_NEW_USER=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
  #get username idqq
  USERNAME_ID=$($PSQL "SELECT username_id from usernames where username='$USERNAME'")
  #echo welcome
  echo -e "\nWelcome, "$USERNAME"! It looks like this is your first time here."
#if found
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE username_id='$USERNAME_ID'")
  BEST_GAME=$($PSQL "SELECT DISTINCT min(number_of_guesses) FROM games where username_id='$USERNAME_ID'")
  #echo welcome with info
  echo -e "\nWelcome back, "$USERNAME"! You have played "$GAMES_PLAYED" games, and your best game took "$BEST_GAME" guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

read NUMBER

FUNCTION ()
{
if [[ $NUMBER ]] && [ $NUMBER -eq $NUMBER 2>/dev/null ]
then
  if [ "$NUMBER" -lt "$GENERATED_NUMBER" ]
  then
    echo "It's lower than that, guess again:"
    read NUMBER
  else [ "$NUMBER" -gt "$GENERATED_NUMBER" ]
    echo "It's higher than that, guess again:"
    read NUMBER
  fi
else
  echo "That is not an integer, guess again:"
  read NUMBER
fi
}

i=1

until [ "$NUMBER" -eq "$GENERATED_NUMBER" ] 2>/dev/null
do 
  FUNCTION
  ((i++))
done

ADD_NEW_GAME=$($PSQL "INSERT INTO games(username_id, number_of_guesses) VALUES('$USERNAME_ID', '$i')")

echo "You guessed it in $i tries. The secret number was $GENERATED_NUMBER. Nice job!"
