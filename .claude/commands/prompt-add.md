Add a new prompt to the prompt-master/ library.

The user wants to create a new reusable prompt. The argument is: $ARGUMENTS

Steps:
1. Ask the user for the following details (skip any provided in the argument):
   - Category (catering, events, vendors, talent, marketing, finance, meetings, operations — or a new one)
   - Prompt title (e.g., "Sponsorship Deck Draft")
   - Use case (one-line description)
   - What inputs/placeholders the prompt needs
   - The prompt text itself (or ask the user to describe what the prompt should do and draft it for them)
2. Create the prompt file using the template from prompt-master/README.md:
   - File goes in prompt-master/{{ category }}/{{ kebab-case-title }}.md
   - Include: title, category, use case, tools, last updated, inputs, prompt, and optional example output and notes
3. If the category folder doesn't exist yet, create it and update the category table in prompt-master/README.md.
4. Show the user the completed file for review before saving.
