Task 4: Local Variables
Create local_demo.sh with:
A function that uses local keyword for variables
Show that local variables don't leak outside the function
Compare with a function that uses regular variables


#!/usr/bin/env bash

name="Iron Man"

update_variable() {

        local name="Iron Women" # By using local the scope of the variable name is just inside the function 
        echo $name
}

update_variable
echo $name


root@ubuntu-host ~/scripts ➜  ./local_demo.sh 
Iron Women
Iron Man
