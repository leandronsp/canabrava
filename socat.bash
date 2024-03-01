#!/bin/bash

socat TCP-LISTEN:3000,reuseaddr,fork,max-children=5 EXEC:"./app/handler.bash"
