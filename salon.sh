#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Salon Appointment Scheduler ~~\n"

SALON() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome, how can I help you?\n"

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read NUM BAR NAME
  do
    echo "$NUM) $NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_NAME ]]
  then 
    SALON "Service not found."
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    echo -e "\nWhat time would you like your $( echo $SERVICE_NAME | sed -r "s/^ *//g" ), $( echo $CUSTOMER_NAME | sed -r "s/^ *//g" )?"
    read SERVICE_TIME

    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $( echo $SERVICE_NAME | sed -r "s/^ *//g" ) at $SERVICE_TIME, $( echo $CUSTOMER_NAME | sed -r "s/^ *//g" )."
  fi
}

SALON
