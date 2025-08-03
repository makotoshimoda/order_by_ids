#!/bin/bash

# Configurable branch and remote
BRANCH_NAME="test2"
REMOTE_NAME="origin"

# Get today's date in JST (end of day, 23:59:59 +0900)
TODAY=$(date -v +9H +"%Y-%m-%dT23:59:59+0900")

# Fetch latest remote state
git fetch "$REMOTE_NAME"

# Get commit hashes and commit dates (ISO 8601), newest first
COMMITS_TO_PUSH=$(git log "$BRANCH_NAME" --pretty=format:'%H %cI %s' \
  | awk -v today="$TODAY" '
    $2 <= today {
      print $1
    }')

# Check if we found any commits
if [ -z "$COMMITS_TO_PUSH" ]; then
  echo "❌ No commits found before or on $TODAY"
  exit 1
fi

# Get the newest commit to push
LAST_ALLOWED_COMMIT=$(echo "$COMMITS_TO_PUSH" | head -n 1)

# Check if the commit is already in the remote branch
if git merge-base --is-ancestor "$LAST_ALLOWED_COMMIT" "$REMOTE_NAME/$BRANCH_NAME" 2>/dev/null; then
  echo "✅ Commit $LAST_ALLOWED_COMMIT is already in $REMOTE_NAME/$BRANCH_NAME"
  exit 0
fi

# Collect commits to display (from origin/test-branch or initial commit to LAST_ALLOWED_COMMIT)
if git rev-parse "$REMOTE_NAME/$BRANCH_NAME" >/dev/null 2>&1; then
  COMMIT_RANGE="$REMOTE_NAME/$BRANCH_NAME..$LAST_ALLOWED_COMMIT"
else
  COMMIT_RANGE="$LAST_ALLOWED_COMMIT"
fi

echo "✅ Commits to be pushed to $REMOTE_NAME/$BRANCH_NAME:"
echo "--------------------------------------------------"
git log "$COMMIT_RANGE" --pretty=format:'Hash: %H%nDate: %cI%nMessage: %s%n--------------------------------------------------'
echo

# Prompt for confirmation
read -p "Do you approve pushing these commits? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "❌ Push aborted by user"
  exit 1
fi

# Force-push for clean branch testing
echo "⚠️ Force-pushing to $REMOTE_NAME/$BRANCH_NAME (clean branch mode)"
git push --force "$REMOTE_NAME" "$LAST_ALLOWED_COMMIT:$BRANCH_NAME"

if [ $? -eq 0 ]; then
  echo "✅ Successfully pushed up to $LAST_ALLOWED_COMMIT"
else
  echo "❌ Push failed. Check remote branch state or try manual push:"
  echo "git push --force $REMOTE_NAME $LAST_ALLOWED_COMMIT:$BRANCH_NAME"
  exit 1
fi
