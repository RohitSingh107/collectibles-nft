from ape import accounts, project
from ape.cli import get_user_selected_account

def main():
    # deployer = accounts.load('rohit_dev')
    deployer = get_user_selected_account()
    print("Hello")
    print(deployer)

