#!/bin/bash

cd vagrant || exit
vagrant destroy -f jobmanager taskmanager-1 taskmanager-2

ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:2220"
ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:2221"
ssh-keygen -f ~/.ssh/known_hosts -R "[localhost]:2222"

vagrant up