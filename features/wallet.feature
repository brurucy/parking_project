Feature: user credit
  As a registered user
  I want to charge my wallet and see the list of transactions for charging my wallet
  So I go to the App
  to deposite some money

  Scenario: Charging my wallet
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on "my_wallet_button" button
    And My current balance is "50"
    And it takes me to the index of the wallet
    When I fill the form with "200" as the amount
    And submit it
    Then it should charge my wallet and show me "250" as my balance
    Then I click to log-out

  Scenario: showing the transactions for charging my wallet
    Given that I am logged in with the following credentials "bruno98@ut.ee" and password "parool"
    And I am on the App
    Then I click on "my_wallet_button" button
    And it takes me to the index of the wallet
    Then it shows me all of the transactions for charging my wallet