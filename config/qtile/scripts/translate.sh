#!/bin/bash

dunstify "$(xsel -o)" "$(wget -U "Mozilla/5.0" -qO - "http://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=sk&dt=t&q=$(xsel -o)" | awk -F'"' '{print $2}')"
