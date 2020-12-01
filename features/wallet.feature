Feature: user credit
  As a registered user
  I want to charge my wallet and see the list of transactions for charging my wallet
  So I go to the App
  to deposite some money

  Scenario: Charging my wallet
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on "my_wallet_button" button
    And My initial balance "50.5" is added
    When I fill the form with "200" as the amount
    And submit it
    Then it should show me "250.5" as my balance
    Then I click to log-out

  Scenario: showing the transactions for charging my wallet
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on "my_wallet_button" button
    And it takes me to the index of the wallet
    And I charge my wallet two times with amounts "120" and "30"
    Then it should show me two transactions with amounts of "120" and "30"