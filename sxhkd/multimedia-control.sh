#!/bin/bash

if grep -e "suspend cause: USER" <(pacmd info) ; then
            pacmd suspend 0
        else
            pacmd suspend 1
    fi
