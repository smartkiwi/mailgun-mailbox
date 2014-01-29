Feature: Validating Mailgun Mailbox functionality
  Scenario: Finding message with random address
    When I send email to random mailbox with random subject
    Then I can load this message from mailbox

  Scenario: Deleting message
    When I send email to random mailbox with random subject
    Then I can load this message from mailbox
    When I delete this message
    Then I don't see this message in mailbox
