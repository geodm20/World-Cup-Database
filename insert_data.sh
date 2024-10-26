#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# This is to delete tables and not overcharge the DB on each file run
echo $($PSQL "TRUNCATE TABLE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
# Ignore all values from the first line of the file
if [[ $WINNER != "winner" || $OPPONENT != "opponent" || $YEAR != "year" ]]
then 

  # Insert all winner teams if not present
  # get the name of the winner
  WINNER_TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")
  if [[ -z $WINNER_TEAM ]] # if the team name does not exist, then add it
  then 
    INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]
    then # if the name was inserted, give a message
      echo Inserted winner team: $WINNER
    fi
  fi

  # Insert all opponent teams if not present
  # get the name of the opponent
  OPPONENT_TEAM=$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")
  if [[ -z $OPPONENT_TEAM ]] 
  then # if doesn't exist, then add it
    INSERT_OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_TEAM != "INSERT 0 1" ]]
    then # if it's inserted, then say it
      echo Inserted opponent team: $OPPONENT
    fi
  fi

  # Now let's insert data on the games table
  # Get winner and opponent IDs from teams table and get them into games
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  INSERT_GAME=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
  VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAME == "INSERTED 0 1" ]]
  then # echo it
    echo Inserted game: $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
  fi

fi
done