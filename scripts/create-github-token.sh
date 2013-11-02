# Areates a github token to use to create and delete repos.
# Add this token to `github_setup_token` in secrets.js.
#
# USAGE: github_login="user:password" sh create-github-token.sh
 curl -i -XPOST \
  -u "$github_login" \
  -H 'Content-Type: application/json' \
  -d '{
    "scopes": ["public_repo", "repo", "repo:status", "delete_repo"],
    "note": "nko repo setup script"
  }' \
  "https://api.github.com/authorizations"
