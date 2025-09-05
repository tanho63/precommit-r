# tanho63/precommit-r: air and flir in a docker container

## Goals

Create an R [precommit](https://pre-commit.com/) config that includes:

- a faster and more robust styler via [air](https://posit-dev.github.io/air/)
- automated linting fixes via [flir](https://flir.etiennebacher.com/)
- centralized linter/styler config management
- custom linters automatically applied and updated locally

via a central docker image that can be used by all team/org members

## Usage

- Build the docker image with `./build.sh`, adding -p flag to tag as production and the -w flag to push to AWS ECR
- [Set up](https://pre-commit.com/#install) precommit (bonus points for using uv / uvx tool install).
- Copy [.pre-commit-config.yaml](./.pre-commit-config.yaml) to your repo
- `pre-commit install` to install the config
- then run normal git add + commit to see precommit in action

```sh
# ensure precommit is installed
pre-commit install
# create a file to test commits
echo '
library(flir)
# styling tests
mtcars |> dplyr::mutate(a_very_long_string = "zyxalkjsdaf;lwkejrfa;lsikdejf;aslodkifja;soldjfk",
indented_oddly = "pie")

# custom linting tests
browser()

# TODO this is a bad todo comment
"bad todo"

# TODO(ZSOC-1234) this is a good todo comment
"good todo"

# TODO this is a nolinted todo
"respect nolint on todo"
' > test.R
# commit this file
git add test.R
git commit -m 'test'
# see pre-commit outputs, both the diff and how it errors and calls out line numbers of lint errors it can't fix
```
