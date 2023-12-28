# DNSControl Action

Deploy your DNS configuration using [GitHub Actions](https://github.com/actions)
using [DNSControl](https://github.com/StackExchange/dnscontrol/).

## Usage

These are the three relevant sub commands to use with this action.

### Check and Preview

We will start with the GitHub Actions workflow that checks the `dnsconfig.js` file for a valid configuration, and gives you a nice preview of your changes in the form of a comment on your pull request.This action does not communicate with the DNS providers, hence does not require
any secrets to be set. In `.github/workflows/check-and-preview.yml`, put the following:

```yaml
name: Check and Preview DNS changes

on:
  pull_request:
    types:
      - opened
    branches:
      - 'dns-update'
    paths:
      - 'dnsconfig.js'

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Check DNS configuration
        uses: dan-is-not-the-man/dnscontrol-action@v4.7.3-beta.1
        with:
          args: check

  preview:
    runs-on: ubuntu-latest
    needs: check
    steps:
      - uses: actions/checkout@v3
      - name: Preview DNS changes
        id: preview
        uses: dan-is-not-the-man/dnscontrol-action@v4.7.3-beta.1
        env:
          DESEC_API_TOKEN: ${{ secrets.DESEC_API_TOKEN }}
        with:
          args: preview
      - name: Comment diff on PR
        uses: unsplash/comment-on-pr@v1.3.0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          msg: |
            ```
            ${{ steps.preview.outputs.output }}
            ```
          check_for_duplicate_msg: true
```

### Push

When you merge the pull request with your DNS changes, you probably want those changes to be pushed up to DeSec automatically. So we will work on that next.

Edit the file `.github/workflows/push.yml` and fill it with the following:

```yaml
name: Push DNS changes

on:
  push:
    branches:
      - main
    paths:
      - 'dnsconfig.js'

jobs:
  push:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Push DNS changes
        uses: dan-is-not-the-man/dnscontrol-action@v4.7.3-beta.1
        env:
          DESEC_API_TOKEN: ${{ secrets.DESEC_API_TOKEN }}
        with:
          args: push
```

This is the action you probably want to run for each branch so that proposed changes
could be verified before an authorized person merges these changes into the default
branch.

#### Pull request comment

```
 ******************** Domain: example.com
----- Getting nameservers from: desec
----- DNS Provider: desec...6 corrections
#1: CREATE record: @ TXT 1 v=spf1 include:_spf.google.com -all
#2: CREATE record: @ MX 1 1  aspmx.l.google.com.
#3: CREATE record: @ MX 1 5  alt1.aspmx.l.google.com.
#4: CREATE record: @ MX 1 5  alt2.aspmx.l.google.com.
#5: CREATE record: @ MX 1 10  alt3.aspmx.l.google.com.
#6: CREATE record: @ MX 1 10  alt4.aspmx.l.google.com.
----- Registrar: none...0 corrections
Done. 6 corrections.
```


## Credentials

Depending on the DNS providers that are used, this action requires credentials to
be set. These secrets can be configured through a file named `creds.json`. You
should **not** add secrets as plaintext to this file, but use GitHub
Actions [encrypted secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)
instead. These encrypted secrets are exposed at runtime as environment variables.
See the DNSControl [Service Providers](https://stackexchange.github.io/dnscontrol/provider-list)
documentation for details.

To follow the DeSec example, add an encrypted secret named `DESEC_API_TOKEN`
and then define the `creds.json` file as follows.

```json
{
  "desec": {
    "TYPE": "DESEC",
    "auth-token": "your-deSEC-auth-token"
  }
}
```

## Dependabot

[Dependabot](https://docs.github.com/en/github/administering-a-repository/keeping-your-actions-up-to-date-with-github-dependabot)
is a GitHub service that helps developers to automate dependency maintenance and
keep dependencies updated to the latest versions. It has native support for
[GitHub Actions](https://docs.github.com/en/github/administering-a-repository/configuration-options-for-dependency-updates#package-ecosystem),
which means you can use it in your GitHub repository to keep the DNSConrol Acion
up-to-date.

To enable Dependabot in your GitHub repository, add a `.github/dependabot.yml`
file with the following contents:

```yaml
version: 2
updates:
  # Maintain dependencies for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```
