#!/bin/bash
PSQL="psql -t --username=freecodecamp --dbname=salon -c"
echo -e "\n~~~ My Salon ~~~"
MAIN_MENU() {
  if [[ -z $1 ]]
  then
  echo -e "\nWelcome to My Salon. How can I help you?"
  else
  echo -e "\n$1"
  fi
  #list of services from db
  SERVICES_FROM_DB=$($PSQL "SELECT CONCAT(service_id, ') ', name) FROM services")
  echo "$SERVICES_FROM_DB"
  read SERVICE_ID_SELECTED
  SERVICE_NAME_FROM_DB=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if service does not exists
  if [[ -z $SERVICE_NAME_FROM_DB ]]
  then
  #then main menu again with message
  MAIN_MENU "I could not find that service. What would you like today?"
  fi
  SERVICE_NAME=$(echo $SERVICE_NAME_FROM_DB | sed -E 's/^ *| *$//g')
}
MAIN_MENU
#what's your phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
#read customer name from db
CUSTOMER_NAME_FROM_DB=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
#if customer does not exists
if [[ -z $CUSTOMER_NAME_FROM_DB ]]
then
#ask for name
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME
#insert new customer into db
INSERTED_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
else
CUSTOMER_NAME=$(echo $CUSTOMER_NAME_FROM_DB | sed -E 's/^ *| *$//g')
fi

#ask for service time
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
#insert service with time into db
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
APPOINTMENT_INSERTED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
#print message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."