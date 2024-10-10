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

- [x] unique tag after action
  - [x] dedicated tag method
  - [x] don't add tags if already present
  - [x] remove requirement of argument for cycle tag
- [ ] checking action in Next Actions list completes in project
  - [ ] checking action gracefully handles missing tag
- [x] checking action in project completes in Next Actions list
- [x] dedicated "gtd" action for "checking"
- [ ] some way to sync: while scraping, if action checked anywhere, check everywhere

### Add to Next Actions

- [x] TargetAsNextActions
- [x] ToggleNextAction
- [x] UntargetNextAction
- [x] Helper methods
  - [x] is_action_targeted
  - [x] tag_action_as_targeted
  - [x] target_action
    - [x] tag it as targeted, add it to next-actions under context
    - [x] this could mark it as the next action: [◎] (<c-k>0o)
    - [x] is_action_in_file or is_id_in_file
    - [x] ensure no duplicates in next-actions
    - [x] expose as top level function
    - [x] fix bug: targetting now retains indentation level
    - [x] Change user function to a toggle
      - [x] Refactor into one top level and mutliple helper
      - [x] Test that untargeting removes from NextActions file
    - [x] Don't include target in NextActions file
    - [x] Write next-actions file after additions

### Add dependencies / waiting for

Have some way to chain dependencies between tasks, i.e. list a action as
"blocked" by another action (by tag), such that when the blocking action is
checked, the now unblocked action becomes targeted

Consider if there's a way to elegantly handle "waiting fors"
  - have a "check up" date/time on each waiting for

### Scraping actions (low-prio)

**Deemed too blunt an approach for now. Dismissed in favour of
manually targeting actions in project files**

- [ ] avoid duplicates
- [ ] put new at bottom of list
- [ ] use built in [lua file reading](/home/crundallt/opt/neovim/build/share/nvim/runtime/doc/luaref.txt) file:lines()

### Tidying

- [x] ignore undefined global in test file
- [x] use parametrization in tests

### Future features

- [x] feat: actually make it a plugin
  - [x] configure location of next-actions file
- [ ] feat: delete checked tasks
- [x] feat: connected actions
- [ ] feat: template a project file
- [x] feat: configure root directory
- [ ] feat: add table methods
- [ ] feat: include link following
  - [ ] jump to markdown headers in other files
  - [ ] jump to other reference of tag

## Supporting Material

Test are done with [mini.test](https://github.com/echasnovski/mini.test) which is part of
[mini.nvim](https://github.com/echasnovski/mini.nvim/blob/main/README.md)
- See [examples here](https://github.com/echasnovski/mini.nvim/blob/main/TESTING.md#test-parametrization)
