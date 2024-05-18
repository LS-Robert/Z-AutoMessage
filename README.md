# Z-AutoMessage

🚀 **System Description:**

Z-AutoMessage is a lightweight script designed to facilitate automatic message sending in the chat. It is useful for those who want to schedule messages to be sent automatically at defined intervals in the server chat. For example, you can set up a message like "Join our Discord server for updates and special events".

---

**Key Features:**

- Sends automatic messages in the chat at configurable intervals.
- Simple command interface for managing and configuring messages.
- Allows dynamic editing and deletion of scheduled messages.
- Saves messages and modification history in JSON files within the script folder.

---

🔧 **Available Commands:**

- `/addcommand "message" interval_in_minutes`: Adds a new automatic message with the specified text and time interval in minutes.
- `/editcommand id "new_message"`: Edits the existing automatic message with the specified ID.
- `/deletecommand id`: Deletes the automatic message with the specified ID.
- `/seecommands`: Displays a list of all scheduled automatic messages.
- `/reloadcommands`: Reloads automatic messages from the configuration file.

---
