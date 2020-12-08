Feature: Interactive search of parking space
  As a registered user
  I want to park my car
  So I go to the App
  to find a parking place
  near me

  Scenario: Transition from providing an address to displaying the list of available parking spaces (2.1)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "search" button
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "2000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And submit it
    Then I should see the available parking places with the given Radius constraint

  Scenario: The system shows the space availability and information about the price that applies (Zone A vs. B) (2.2)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "search" button
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And submit it
    Then I should see the price, zone and availability

  Scenario: The system estimates the fee in hourly payment (if the user enters the intended leaving hour). (2.3)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "search" button
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And know that my payment scheme is hourly
    And submit it
    Then I should see the estimated hourly fee
#
  Scenario: The system estimates the fee in real-time payment (if the user enters the intended leaving hour). (2.4)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "search" button
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And know that my payment scheme is real-time
    And submit it
    Then I should see the estimated real-time fee
#
  Scenario: The system allows a car driver to select hourly payment. (3.1a, 3.2)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "payment_scheme" button
    And select hourly
    And submit it
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And know that my payment scheme is hourly
    And submit it
    Then I should see the estimated hourly fee
    When I click "Book Vabriku 1"
    Then I should get a confirmation
#
  Scenario: The system allows a car driver to select real-time payment. (3.1b)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "payment_scheme" button
    And select real-time
    And submit it
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And know that my payment scheme is real-time
    And submit it
    Then I should see the estimated real-time fee
    When I click "Book Vabriku 1"
    Then I should get a confirmation
#
  Scenario: The driver can extend the parking period. (3.5)
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on the "search" button
    And it takes me to the search form
    Given that I want to go to "Raatuse 23"
    And I dont want to park more than "5000" metres away from it
    Given that I select year "2020" month "December" day "10" hour "10" minute "10"
    Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
    Given the following parking spaces are available
      | Spot      | Category | Places | Distance |
      | Vabriku 1 |  A       | 3      | 1661     |
      | Lossi 21  |  B       | 30     | 1736     |
      | Jakobi 2  |  B       | 50     | 2884     |
    And submit it
    When I click "Book Vabriku 1"
    Then I should get a confirmation
    Then I click on the "my_parking_button" button
    And I see the booking on "Vabriku 1"
    Then I click on "Extend"
    And I extend it by an hour
    And submit it
    Then I should see the end date extended by one hour and the fee by 200 cents

  #Scenario: (On hourly-based payment) The system allows the driver to pay before starting the parking period. (4.1)
  #  Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
  #  And I am on the App
  #  Then I click on the "payment_scheme" button
  #  And select hourly
  #  And submit it
  #  Then I click on the "wallet" button
  #  And it takes me to the wallet form
  #  Then I add "1000" cents to my wallet
  #  And I get a confirmation of adding "1000" cents
  #  Then I click on the "search" button
  #  Given that I want to go to "Raatuse 23"
  #  And I dont want to park more than "5000" metres away from it
  #  Given that I select year "2020" month "December" day "10" hour "10" minute "10"
  #  Given that I select year "2020" month "December" day "10" hour "11" minute "10" as end date
  #  Given the following parking spaces are available
  #    | Spot      | Category | Places | Distance |
  #    | Vabriku 1 |  A       | 3      | 1661     |
  #    | Lossi 21  |  B       | 30     | 1736     |
  #    | Jakobi 2  |  B       | 50     | 2884     |
  #  And submit it
  #  When I click to "Book Vabriku 1"
  #  Then I should get a confirmation
  #  Then I click on the "wallet" button
  #  And it takes me to the wallet form
  #  And I see an invoice showing "-200" cents