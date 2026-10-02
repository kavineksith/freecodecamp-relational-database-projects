#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo "Welcome to My Salon, how can I help you?"
echo

# Display services
$PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

echo

# Ask for service
read SERVICE_ID_SELECTED

# Check if service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

while [[ -z $SERVICE_NAME ]]
do
  echo
  echo "I could not find that service. What would you like today?"

  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
done

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

# Find existing customer
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist
if [[ -z $CUSTOMER_NAME ]]
then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get customer ID
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Create appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."