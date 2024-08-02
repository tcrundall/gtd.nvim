# Getting Things Done Plugin

**WORK IN PROGRESS**

A plugin that facilitates utilizing the Getting Things Done framework in Neovim.

(Potential) Features include:

* Scraping actions from project files into centralized Next Action list
* Linking blocked actions to their blocker
* Auto-unblocking blocked actions upon completion of their blocker

## Brainstorm

## Organize

### Connect actions

- [ ] unique tag after action
  - [x] dedicated tag method
  - [x] don't add tags if already present
  - [x] remove requirement of argument for cycle tag
- [ ] checking action in Next Actions list completes in project [](asdf)
- [ ] checking action in project completes in Next Actions list
- [ ] dedicated "gtd" action for "checking"
- [ ] some way to sync: while scraping, if action checked anywhere, check everywhere

### Scraping actions

- [ ] avoid duplicates
- [ ] put new at bottom of list
- [ ] use built in [lua file reading](/home/crundallt/opt/neovim/build/share/nvim/runtime/doc/luaref.txt) file:lines()

### Tidying

- [x] ignore undefined global in test file
- [x] use parametrization in tests

### Future features

- [ ] feat: actually make it a plugin
- [ ] feat: delete checked tasks
- [ ] feat: connected actions
- [ ] feat: template a project file
- [ ] feat: configure root directory
- [ ] feat: add table methods
- [ ] feat: include link following
  - [ ] jump to markdown headers in other files

## Supporting Material

Test are done with [mini.test](https://github.com/echasnovski/mini.test) which is part of
[mini.nvim](https://github.com/echasnovski/mini.nvim/blob/main/README.md)
- See [examples here](https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#test-parametrization)
