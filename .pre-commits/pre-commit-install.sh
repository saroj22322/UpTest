#! /bin/sh

check_program() {
    if [ $1 -eq 0 ]; then
        echo $2 
    else
        echo $3
        exit 1
    fi
}


#check if Python3 is installed
which python3 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    PYTHON=$(which python3)
    echo "Python 3 installation found!"
else
    which python >/dev/null 2>&1
    check_program $? "Python installed found!" "Python 3 installation is not found. Please install Python 3.x first!"
    PYTHON=$(which python)
fi

#check if unzip is installed
eval which unzip >/dev/null 2>&1
check_program $? "Unzip already installed!" "Unzip installation not found. Please install unzip utility tool first!"

#check if terraform is installed
eval which terraform >/dev/null 2>&1
check_program $? "Terraform already installed!" "Terraform installation not found. Please install terraform first!"

#check the runtime env : Docker or host?
eval ls /.dockerenv >/dev/null 2>&1

if [ $? != 0 ]; then
    echo "Setting virtualenv"
    #check if pip .venv folder is present
    eval ls .venv/bin/activate >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "venv already present!"
    else
        eval "$PYTHON" -m venv -h >/dev/null 2>&1  
        check_program $? "Venv module found !" "Python venv module not found, install python3-venv ( example: sudo apt install python3-venv )"
        eval "$PYTHON" -m venv .venv >/dev/null 2>&1  
        check_program $? "Venv .venv created successfully !" "Error in venv creation, ensure python module venv is installed! ( example: sudo apt install python3-venv )"
    fi

    #activate python venv
    eval . .venv/bin/activate

    #check if Python3 is installed
    which python3 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        PYTHON=$(which python3)
        echo "Python 3 installation found!"
    else
        which python >/dev/null 2>&1
        check_program $? "Python installed found!" "Python 3 installation is not found. Please install Python 3.x first!"
        PYTHON=$(which python)
    fi
fi

echo "Using python from this location : $PYTHON"

#check if pip module is installed
eval "$PYTHON" -m pip --version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Pip already installed!"
else
    curl -O "https://bootstrap.pypa.io/get-pip.py" && (eval "$PYTHON" get-pip.py; rm get-pip.py)
    eval "$PYTHON" -m pip --version >/dev/null 2>&1
    check_program $? "Pip installed successfully !" "Error in Pip installation!"
fi


#check if pre-commit is installed
eval "$PYTHON" -mpip show pre-commit >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Pre-commit already installed!"
else
    eval "$PYTHON" -mpip install --no-cache-dir pre-commit
    eval "$PYTHON" -mpip show pre-commit >/dev/null 2>&1
    check_program $? "Pre-commit installed successfully !" "Error in Pre-commit installation!"
fi

#check if checkov is installed
eval "$PYTHON" -mpip show checkov >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Checkov already installed!"
else
    eval "$PYTHON" -mpip install --no-cache-dir checkov markupsafe==2.0.1
    eval "$PYTHON" -mpip show checkov >/dev/null 2>&1
    check_program $? "Checkov installed successfully !" "Error in checkov installation!"
fi

#check if terraform docs is installed
DOC=/usr/local/bin/terraform-docs
if [ -f $DOC ]; then
    echo "Terraform docs found!"
else
    curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -E -m 1 "https://.+?-linux-amd64.tar.gz")" > terraform-docs.tgz && tar -xzf terraform-docs.tgz terraform-docs && rm terraform-docs.tgz && chmod +x terraform-docs && mv terraform-docs /usr/local/bin/
    eval which terraform-docs >/dev/null 2>&1
    check_program $? "Terraform docs installed successfully" "Error in terraform docs installation!"
fi


#check if terraform lint is installed
LINT=/usr/local/bin/tflint
if [ -f $LINT ]; then
    echo "Terraform lint found!"
else
    curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E -m 1 "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && mv tflint /usr/local/bin/
    eval which tflint >/dev/null 2>&1
    check_program $? "Terraform lint installed successfully" "Error in terraform lint installation!"
fi

#Install pre-commit config to repo
# need to add the the repo, because we changed the pre-commit command. There is probably a better way to do this.
git config --global --add safe.directory .
pre-commit install

cp ./.pre-commits/.pre-commit-config.yaml.sample ./.pre-commit-config.yaml
