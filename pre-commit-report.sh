#! /bin/sh

git_location=$(git rev-parse --show-toplevel)

#check the runtime env : Docker or host?
eval ls /.dockerenv >/dev/null 2>&1

if [ $? != 0 ]; then
    eval . .venv/bin/activate
fi

pre-commit run -c "$git_location"/.pre-commits/.pre-commit-report.yaml -a 2>&1 | tee .tf-pre-commit-report.txt

echo "Report saved to .tf-pre-commit-report.txt"
exit 0