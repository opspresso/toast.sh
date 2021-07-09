#!/bin/bash

alias t='toaster'
alias tu='t update'
alias tt='t tools'

c() {
    toaster cdw ${1}
    if [ -f /tmp/toaster-temp-result ]; then
        cd $(cat /tmp/toaster-temp-result)
    fi
}

ibrew() {
  arch --x86_64 /usr/local/bin/brew $@
}

alias e='toaster env'
alias n='toaster git'
alias q='toaster assume'
alias r='toaster region'
alias s='toaster ssh'
alias v='toaster vsc'
alias x='toaster ctx'
alias z='toaster ns'

alias a='aws'
alias k='kubectl'
alias h='helm'

alias iam='aws sts get-caller-identity | jq .'

alias av='aws-vault'

alias da='export AWS_VAULT= && av exec daangn/alpha'
alias dp='export AWS_VAULT= && av exec daangn/prod'

# alias da='export AWS_PROFILE="daangn/alpha" && aws configure sso && aws sts get-caller-identity | jq .'
# alias dp='export AWS_PROFILE="daangn/prod" && aws configure sso && aws sts get-caller-identity | jq .'

alias tf='terraform'
alias tfc='rm -rf .terraform && rm -rf .terraform.*'
alias tfi='tf init'
alias tfp='tf init && tf plan'
alias tfa='tf init && tf apply'
alias tfd='tf init && tf destroy'
alias tff='tf init && tf fmt'
alias tfg='tf init && tf graph'
alias tfo='tf init && tf output'

alias tfdoc="terraform-docs markdown"

alias py='python'
alias py3='python3'

alias dt='date -u +"%Y-%m-%dT%H:%M:%SZ"'

# alias p='reveal-md -w --port 8888 --theme https://raw.githubusercontent.com/nalbam/docs/master/.theme/black.css'
alias p='reveal-md -w --port 8888 --theme night'

alias chrome="/Applications/Google\\ \\Chrome.app/Contents/MacOS/Google\\ \\Chrome"

alias st="/Applications/Sublime\\ Text.app"

# export GOPATH=$HOME/work
# export PATH=$PATH:$GOPATH/bin
