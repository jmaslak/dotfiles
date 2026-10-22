# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/jmaslak/.docker/bin"
# End of Docker Desktop section.

#!/bin/bash
# ~/.bash_profile: executed by bash
# We just run .profile

if [ -e "$HOME/.profile" ] ; then
    # shellcheck source=/home/jmaslak/.profile
    . "$HOME/.profile"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
