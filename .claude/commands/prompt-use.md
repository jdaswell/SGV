Use a prompt from the prompt-master/ library.

The user wants to run a prompt. The argument is: $ARGUMENTS

Steps:
1. Search prompt-master/ for a prompt matching the argument (by filename, category, or keyword in the use case description). If the argument is empty, list all available prompts and ask which one to use.
2. Read the full prompt file.
3. Show the user the prompt template and identify all {{ placeholder }} tokens.
4. Ask the user to provide values for each placeholder.
5. Fill in the placeholders and run the completed prompt.
6. Present the output for the user to review, edit, or approve.
