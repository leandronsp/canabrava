#!/bin/bash

socat TCP-LISTEN:3000,reuseaddr,fork,max-children=2 EXEC:"./app/handler.bash"
