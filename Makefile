.PHONEY: iac-validate build

iac-validate:
	cd ./backend/iac && terraform init -backend=false && terraform validate

build: iac-validate